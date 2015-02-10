require 'nutrition_calculator/cached_outputs_with_recalculation'

module NutritionCalculator
  # Calculates Calorie Budget Per Day in Weekly Context
  #
  # The `NutritionCalculator::CalorieBudgeter` is used to determine how many
  # calories you need to consume and how many calories you need to burn via
  # exercise for a given day in order to stay on target with your diet. In
  # particular, it ensures that you consume at least enough to satisfy your
  # resting metabolic rate each day, even if that means you need to burn off
  # calories via exercise to keep on track. It operates on a weekly basis,
  # so if you are over-/under-budget on a given day, the goals for the
  # remainder of the week will be adjusted accordingly.
  # 
  # @example
  #   cb = NutritionCalculator::CalorieBudgeter.new
  #   
  #   cb.resting_metabolic_rate = 2_000 # calories per day
  #   cb.weekly_calorie_goal = 10_500 # creates an average deficit of 500 calories/day
  #   cb.current_day_of_week = 3 # if your week starts on Monday, this would be Wednesday
  #   cb.prior_days_calories = 3_524 # net calories from Monday and Tuesday
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

    # @!group Inputs

    # @!attribute
    # @return [Integer] The daily resting metabolic rate in calories
    def_input :resting_metabolic_rate

    # @!attribute
    # @return [Integer] The total net calories (consumed - burned) planned for
    #                   the week
    def_input :weekly_calorie_goal

    # @!attribute
    # @return [Integer] The total net calories from all days this week prior
    #                   to the current day
    # @example
    #   If it is currently Wednesday
    #   And on Monday you consumed 100 calories and burned 75 for a net of 25
    #   And on Tuesday you consumed 200 calories and burned 100 for a net of 100
    #   Then you don't care about today's calories
    #   And the value for this input should be 125 (Monday + Tuesday)
    def_input :prior_days_calories

    # @!attribute
    # @return [Integer] The number of the day of the week
    # @example If you start your week on Monday
    #   1 - Monday
    #   2 - Tuesday
    #   3 - Wednesday
    #   4 - Thursday
    #   5 - Friday
    #   6 - Saturday
    #   7 - Sunday
    def_input :current_day_of_week

    # @!attribute
    # @return [Integer] The total number of calories consumed today
    def_input :calories_consumed

    # @!attribute
    # @return [Integer] The total number of calories burned via exercise today
    def_input :calories_burned

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
    #                   consumed) that is greater than the daily calorie goal
    #                   and not yet burned off via exercise
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
    # @return [Integer] The number of net calories that should be consumed today
    #                   to meet the weekly calorie goal
    def_output :daily_calorie_goal do
      (remaining_calories_this_week.to_f / remaining_days_of_week).round
    end

    # @!attribute [r]
    # @return [Integer] The number of calories left in the calorie budget for
    #                   the current week (does not include calories consumed
    #                   today)
    def_output :remaining_calories_this_week do
      weekly_calorie_goal - prior_days_calories
    end

    # @!attribute [r]
    # @return [Integer] The number of days remaining in the week, including the
    #                   current day
    def_output :remaining_days_of_week do
      8 - current_day_of_week
    end
  end
end
