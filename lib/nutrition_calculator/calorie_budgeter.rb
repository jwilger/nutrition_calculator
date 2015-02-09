require 'nutrition_calculator/cached_outputs_with_recalculation'

module NutritionCalculator
  class CalorieBudgeter
    include CachedOutputsWithRecalculation

    def_input :resting_metabolic_rate, 2_000
    def_input :weekly_calorie_goal, 14_000
    def_input :prior_days_calories, 0
    def_input :current_day_of_week, 1
    def_input :calories_consumed, 0
    def_input :calories_burned, 0

    def_output :net_calorie_consumption do
      calories_consumed - calories_burned
    end

    def_output :calories_remaining do
      [0, remaining_to_target].max
    end

    def_output :exercise_calories_remaining do
      [0, predicted_overage].max
    end

    def_output :predicted_calorie_consumption do
      [target_daily_calorie_consumption, calories_consumed].max
    end

    def_output :predicted_overage do
      predicted_calorie_consumption - daily_calorie_goal - calories_burned
    end

    def_output :remaining_to_target do
      target_daily_calorie_consumption - calories_consumed
    end

    def_output :target_daily_calorie_consumption do
      if calories_burned < (resting_metabolic_rate - daily_calorie_goal)
        resting_metabolic_rate
      else
        daily_calorie_goal + calories_burned
      end
    end

    def_output :daily_calorie_goal do
      (remaining_calories_this_week.to_f / remaining_days_of_week).round
    end

    def_output :remaining_calories_this_week do
      weekly_calorie_goal - prior_days_calories
    end

    def_output :remaining_days_of_week do
      8 - current_day_of_week
    end
  end
end
