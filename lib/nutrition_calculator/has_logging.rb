require 'logger'

module NutritionCalculator
  # Provides a few logging utilities to the including class/module
  module HasLogging
    module NullLogger
      extend self

      def noop(*args); args; end
      alias_method :error, :noop
      alias_method :warn, :noop
      alias_method :info, :noop
      alias_method :debug, :noop
    end
    private_constant :NullLogger

    attr_writer :logger

    # The logger to which the including class/module should write
    #
    # Defaults to a NullLogger, which simply discards all logging attempts as
    # noops.
    #
    # @return [Logger] an object adhering to the Logger interface
    def logger
      @logger ||= NullLogger
    end

    protected

    # Executes the block and both logs and returns the result
    #
    # @return [block.call] The result of calling the block provided
    def debug_value(name, &block)
      block.call.tap do |value|
        logger.debug("#{name}: #{value}")
      end
    end
  end
end
