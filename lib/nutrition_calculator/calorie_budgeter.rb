require 'nutrition_calculator/cached_outputs_with_recalculation'

module NutritionCalculator
  # Calculates Calorie Budget Per Day
  #
  # The `NutritionCalculator::CalorieBudgeter` is used to determine how many
  # calories you need to consume and how many calories you need to burn via
  # exercise for a given day in order to stay on target with your diet. In
  # particular, it ensures that you consume at least enough to satisfy your
  # resting metabolic rate each day, even if that means you need to burn off
  # calories via exercise to keep on track. It can operate with diet periods of
  # various lengths; it simply requires information about the net calorie goal
  # for the period, the number of calories already consumed in the period, and
  # the number of days remaining in the period to calculate the net calorie
  # target for the current day.
  # 
  # @example
  #   cb = NutritionCalculator::CalorieBudgeter.new
  #   
  #   cb.resting_metabolic_rate = 2_000 # calories per day
  #
  #   cb.period_calorie_goal = 10_500   # creates an average deficit of 500
  #                                     # calories/day
  #
  #   cb.num_days_to_budget = 5         # The number of days remaining in the
  #                                     # period, including the current day
  #
  #   cb.prior_days_calories = 3_524    # net calories from days 1 and 2
  #   
  #   cb.calories_consumed = 0
  #   cb.calories_burned = 0
  #   
  #   cb.calories_remaining
  #   #=> 2_000 
  #   
  #   cb.exercise_calories_remaining
  #   #=> 605
  #   
  #   cb.calories_consumed = 681 # total calories consumed today
  #   cb.calories_burned = 1752
  #   
  #   cb.calories_remaining
  #   #=> 2_466
  #   
  #   cb.exercise_calories_remaining
  #   #=> 0
  class CalorieBudgeter
    extend CachedOutputsWithRecalculation

    # Instantiates a new CalorieBudgeter
    #
    # @param diet_period [NutritionCalculator::DietPeriod] If provided, the
    #        {#resting_metabolic_rate}, {#period_calorie_goal}, and
    #        {#num_days_to_budget} inputs will be set based on this object.
    # @param source_data [NutritionCalculator::DataSummarizer] If provided, the
    #        {#prior_days_calories}, {#calories_consumed}, and
    #        {#calories_burned} inputs will be set based on this object.
    def initialize(diet_period: nil, source_data: nil)
      self.diet_period = diet_period if diet_period
      self.source_data = source_data if source_data
    end

    # @api nodoc
    # @see #initialize
    def diet_period=(diet_period)
      self.resting_metabolic_rate = diet_period.resting_metabolic_rate
      self.period_calorie_goal = diet_period.net_calorie_goal
      self.num_days_to_budget = diet_period.days_remaining
    end

    # @api nodoc
    # @see #initialize
    def source_data=(source_data)
      self.prior_days_calories = source_data.prior_days_net_calories
      self.calories_consumed = source_data.calories_consumed_today
      self.calories_burned = source_data.calories_burned_today
    end

    # @!group Inputs

    # @!attribute
    # @return [Integer] The daily resting metabolic rate in calories
    def_input :resting_metabolic_rate, validate_with: ->(value) {
      value.kind_of?(Integer) \
        && value > 0
    }

    # @!attribute
    # @return [Integer] The total net calories (consumed - burned) planned for
    #                   the budgeted period
    def_input :period_calorie_goal, validate_with: ->(value) {
      value.kind_of?(Integer)
    }

    # @!attribute
    # @return [Integer] The total net calories from all days prior to the
    #         current day in the diet period
    #
    # @example
    #   If it is currently Wednesday
    #   And your diet period is 7 days long beginning on Monday
    #   And on Monday you consumed 100 calories and burned 75 for a net of 25
    #   And on Tuesday you consumed 200 calories and burned 100 for a net of 100
    #   Then you don't care about today's calories
    #   And the value for this input should be 125 (Monday + Tuesday)
    def_input :prior_days_calories, validate_with: ->(value) {
      value.kind_of?(Integer)
    }

    # @!attribute
    # @return [Integer] The number of days across which to budget the remaining
    #                   net calorie goal. This includes the current day.
    def_input :num_days_to_budget, validate_with: ->(value) {
      (1..7).include?(value)
    }

    # @!attribute
    # @return [Integer] The total number of calories consumed today
    def_input :calories_consumed, validate_with: ->(value) {
      value.kind_of?(Integer) \
        && value >= 0
    }

    # @!attribute
    # @return [Integer] The total number of calories burned via exercise today
    def_input :calories_burned, validate_with: ->(value) {
      value.kind_of?(Integer) \
        && value >= 0
    }

    # @!group Outputs

    # @!attribute [r]
    # @return [Integer] The net calories for the day (consumed - burned via
    #                   exercise)
    def_output :net_calorie_consumption do
      calories_consumed - calories_burned
    end

    # @!attribute [r]
    # @return [Integer] The number of calories remaining to consume today
    def_output :calories_remaining do
      [0, remaining_to_target].max
    end

    # @!attribute [r]
    # @return [Integer] The number of calories that must still be burned today
    #                   in order to meet the daily calorie goal
    def_output :exercise_calories_remaining do
      [0, predicted_overage].max
    end

    # @!attribute [r]
    # @return [Integer] The number of calories that will likely be consumed
    #                   today (the greater of actual consumption or target
    #                   consumption).
    def_output :predicted_calorie_consumption do
      [target_daily_calorie_consumption, calories_consumed].max
    end

    # @!attribute [r]
    # @return [Integer] The number of calories consumed (or predicted to be
    #                   consumed) that is greater than the daily net calorie
    #                   goal and not yet burned off via exercise
    def_output :predicted_overage do
      predicted_calorie_consumption - daily_calorie_goal - calories_burned
    end

    # @!attribute [r]
    # @return [Integer] The number of calories that must still be consumed to
    #                   hit the day's target
    def_output :remaining_to_target do
      target_daily_calorie_consumption - calories_consumed
    end

    # @!attribute [r]
    # @return [Integer] The number of calories that should be consumed today
    def_output :target_daily_calorie_consumption do
      [(daily_calorie_goal + calories_burned), resting_metabolic_rate].max
    end

    # @!attribute [r]
    # @return [Integer] The net calorie budget for the current day that keeps
    #                   the diet on track for the current period
    def_output :daily_calorie_goal do
      (remaining_calories_this_period.to_f / num_days_to_budget).round
    end

    # @!attribute [r]
    # @return [Integer] The number of calories left in the calorie budget for
    #                   the current diet period (does not include calories
    #                   consumed today)
    def_output :remaining_calories_this_period do
      period_calorie_goal - prior_days_calories
    end
  end
end
