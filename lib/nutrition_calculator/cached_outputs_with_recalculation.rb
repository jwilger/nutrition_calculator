require 'nutrition_calculator/has_logging'

module NutritionCalculator
  module CachedOutputsWithRecalculation
    include HasLogging

    def self.included(other)
      other.extend(ClassMethods)
    end

    private

    def cached_values
      @cached_values ||= {}
    end

    def recalculate!
      @cached_values = {}
    end

    def cache(name, &block)
      cached_values.fetch(name) do
        cached_values[name] = block.call
      end
    end

    module ClassMethods
      def def_input(name)
        define_method("#{name}=") do |value|
          recalculate!
          instance_variable_set("@#{name}", value)
        end

        define_method(name) do
          instance_variable_get("@#{name}").tap do |v|
            if v.nil?
              raise RuntimeError, "Required input missing: `#{name}`."
            end
          end
        end
      end

      def def_output(name, &block)
        define_method(name) do
          cache(name) do
            debug_value(name) do
              instance_eval &block
            end
          end
        end
      end
    end
  end
end
