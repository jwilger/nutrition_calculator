module NutritionCalculator
  module HasLogging
    class NullLogger
      def noop(*args);end
      alias_method :error, :noop
      alias_method :warn, :noop
      alias_method :info, :noop
      alias_method :debug, :noop
    end

    def initialize(*args, logger: NullLogger.new)
      self.logger = logger
      super *args
    end

    private

    attr_accessor :logger

    def debug_value(name, &block)
      block.call.tap do |v|
        logger.debug("#{name}: #{v}")
      end
    end
  end
end
