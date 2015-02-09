require 'nutrition_calculator/has_logging'

module NutritionCalculator
  module CachedOutputsWithRecalculation
    def self.extended(other)
      other.include(InstanceMethods)
    end

    def def_input(name)
      def_input_writer name
      def_input_reader name
    end

    def def_output(name, &block)
      define_method(name) do
        cache_and_debug(name, &block)
      end
    end

    private

    def def_input_writer(name)
      define_method("#{name}=") do |value|
        recalculate!
        instance_variable_set("@#{name}", value)
      end
    end

    def def_input_reader(name)
      define_method(name) do
        require_input name
        instance_variable_get("@#{name}")
      end
    end

    module InstanceMethods
      include HasLogging

      private

      def cached_values
        @cached_values ||= {}
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
