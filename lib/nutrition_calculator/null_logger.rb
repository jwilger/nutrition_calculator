module NutritionCalculator
  class NullLogger
    def noop(*args);end
    alias_method :error, :noop
    alias_method :warn, :noop
    alias_method :info, :noop
    alias_method :debug, :noop
  end
end
