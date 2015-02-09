module NutritionCalculator
  class RemainingDailyCaloriesCalculator
    def self.attr_accessor_with_default(name, default)
      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
        recalculate!
      end

      define_method(name) do
        instance_variable_get("@#{name}") \
          || instance_variable_set("@#{name}", default)
      end
    end

    class NullLogger
      def noop(*args);end
      alias_method :error, :noop
      alias_method :warn, :noop
      alias_method :info, :noop
      alias_method :debug, :noop
    end

    attr_accessor_with_default :resting_metabolic_rate, 2_000
    attr_accessor_with_default :weekly_calorie_goal, 14_000
    attr_accessor_with_default :prior_days_calories, 0
    attr_accessor_with_default :current_day_of_week, 1
    attr_accessor_with_default :calories_consumed, 0
    attr_accessor_with_default :calories_burned, 0

    def initialize(logger: NullLogger.new)
      self.logger = logger
    end

    def net_calorie_consumption
      cache(:net_calorie_consumption) do
        calories_consumed - calories_burned
      end
    end

    def calories_remaining
      cache(:calories_remaining) do
        [0, remaining_to_target].max
      end
    end

    def exercise_calories_remaining
      cache(:exercise_calories_remaining) do
        logger.debug "predicted_overage: #{predicted_overage}"
        [0, predicted_overage].max
      end
    end

    def predicted_calorie_consumption
      cache(:predicted_calorie_consumption) do
        logger.debug "target_daily_calorie_consumption: #{target_daily_calorie_consumption}"
        logger.debug "net_calorie_consumption: #{net_calorie_consumption}"
        [target_daily_calorie_consumption, calories_consumed].max
      end
    end

    def predicted_overage
      cache(:predicted_overage) do
        logger.debug "predicted_calorie_consumption: #{predicted_calorie_consumption}"
        logger.debug "daily_calorie_goal: #{daily_calorie_goal}"
        logger.debug "calories_burned: #{calories_burned}"
        predicted_calorie_consumption - daily_calorie_goal - calories_burned
      end
    end

    def remaining_to_target
      cache(:remaining_to_target) do
        logger.debug "target_daily_calorie_consumption: #{target_daily_calorie_consumption}"
        target_daily_calorie_consumption - calories_consumed
      end
    end

    def target_daily_calorie_consumption
      cache(:target_daily_calorie_consumption) do
        logger.debug "calories_burned: #{calories_burned}"
        logger.debug "resting_metabolic_rate: #{resting_metabolic_rate}"
        logger.debug "daily_calorie_goal: #{daily_calorie_goal}"
        if calories_burned < (resting_metabolic_rate - daily_calorie_goal)
          resting_metabolic_rate
        else
          daily_calorie_goal + calories_burned
        end
      end
    end

    def daily_calorie_goal
      cache(:daily_calorie_goal) do
        logger.debug "remaining_calories_this_week: #{remaining_calories_this_week}"
        logger.debug "remaining_days_of_week: #{remaining_days_of_week}"
        (remaining_calories_this_week.to_f / remaining_days_of_week).round
      end
    end

    def remaining_calories_this_week
      cache(:remaining_calories_this_week) do
        logger.debug "weekly_calorie_goal: #{weekly_calorie_goal}"
        logger.debug "prior_days_calories: #{prior_days_calories}"
        weekly_calorie_goal - prior_days_calories
      end
    end

    def remaining_days_of_week
      cache(:remaining_days_of_week) do
        8 - current_day_of_week
      end
    end

    private

    attr_accessor :logger

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
  end
end
