module NutritionCalculator
  module HasLogging
    module NullLogger
      extend self

      def noop(*args);end
      alias_method :error, :noop
      alias_method :warn, :noop
      alias_method :info, :noop
      alias_method :debug, :noop
    end

    attr_writer :logger

    def logger
      @logger ||= NullLogger
    end

    private

    def debug_value(name, &block)
      block.call.tap do |v|
        logger.debug("#{name}: #{v}")
      end
    end
  end
end
