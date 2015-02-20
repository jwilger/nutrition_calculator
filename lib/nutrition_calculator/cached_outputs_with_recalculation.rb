require 'nutrition_calculator/has_logging'

module NutritionCalculator

  # Provides an API to create calculator objects with caching and input
  # validation
  #
  # @api private
  #
  # @example
  #   class Foo
  #     extend NutritionCalculator::CachedOutputsWithRecalculation
  #
  #     def_input :bar
  #
  #     def_input :spam, validate_with: ->(value) {
  #       value != 'ham'
  #     }
  #
  #     def_output :baz do
  #       bar.expensive_operation
  #     end
  #   end
  #
  #   x = Foo.new
  #
  #   x.baz
  #   #=> Raises a RuntimeError because input bar was not set
  #
  #   x.spam = 'ham'
  #   #=> Raises a
  #     NutritionCalculator::CachedOutputsWithRecalculation::InvalidInputError
  #     because the validation returned false.
  #
  #   a_thing = ExpensiveObject.new
  #
  #   x.bar = a_thing
  #   x.baz
  #   #=> result of `a_thing.expensive_operation`
  #
  #   # `a_thing.expensive_operation` will not be called again
  #   x.baz
  #   #=> cached result of `a_thing.expensive_operation`
  #
  #   # `a_thing.expensive_operation` will be called again since input is
  #   # reassigned
  #   x.bar = a_thing
  #   x.baz
  #   #=> result of `a_thing.expensive_operation`
  #
  module CachedOutputsWithRecalculation
    class InvalidInputError < RuntimeError; end

    # @api nodoc
    def self.extended(klass)
      klass.include(InstanceMethods)
    end

    # Defines accessors for the named attribute
    #
    # Assignment to the named accessor will cause all cached results to be
    # recalculated the next time they are called.
    #
    # @param name [Symbol]
    # @param validate_with [Proc] A validation proc that receives the input
    #                             value and must evaluate to `true` if the
    #                             validation passes or `false` if it does not
    def def_input(name, validate_with: ->(_) { true })
      def_input_writer name, validator: validate_with
      def_input_reader name
    end

    # Defines attribute reader methods for the specified calculation
    #
    # The result of the block is cached as long as no inputs are re-assigned
    # after the attribute reader is called. Additionaly, if `#logger` is set,
    # the result of the calculation will be sent to the DEBUG log when the block
    # is run.
    #
    # @param name [Symbol]
    # @param block [Proc] will be `instance_eval`ed in the Object as though it
    #                     were the body of a regular method
    def def_output(name, &block)
      define_method(name) do
        cache_and_debug(name, &block)
      end
    end

    private

    def def_input_writer(name, validator:)
      define_method("#{name}=") do |value|
        validate_input!(name, value, validator)
        recalculate!
        instance_variable_set("@#{name}", value)
      end
    end

    def def_input_reader(name)
      define_method(name) do
        require_input name
        debug_value(name) {
          instance_variable_get("@#{name}")
        }
      end
    end

    module InstanceMethods
      include HasLogging

      private

      def cached_values
        @cached_values ||= {}
      end

      def validate_input!(name, value, validator)
        success = validator.(value)
        if !success
          raise InvalidInputError, "#{value.inspect} is not a valid input value for '##{name}'."
        end
      end

      def recalculate!
        logger.debug "Input received; clearing cached calculations."
        @cached_values = {}
      end

      def cache(name, &block)
        cached_values.fetch(name) do
          cached_values[name] = block.call
        end
      end

      def require_input(name)
        unless instance_variable_defined?("@#{name}")
          raise RuntimeError, "Required input missing: `#{name}`."
        end
      end

      def cache_and_debug(name, &block)
        cache(name) do
          run_and_debug(name, &block)
        end
      end

      def run_and_debug(name, &block)
        debug_value(name) { instance_eval &block }
      end
    end
    private_constant :InstanceMethods
  end
end
