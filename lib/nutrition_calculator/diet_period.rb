require 'date'
require 'nutrition_calculator/cached_outputs_with_recalculation'

module NutritionCalculator
  # The Time-Period for which the Diet is Analyzed
  #
  # Although we tend to look at our diets on a daily basis in terms of tracking
  # against a calorie budget (i.e. "How much more should I eat *today*?"),
  # weight-change goals are set over a longer period of time (i.e. "I want to
  # lose weight at a rate of 1lb per week.") The DietPeriod represents the
  # period of time (in days) over which a person is attempting to lose a certain
  # amount of weight (in kilograms).
  #
  # The DietPeriod is a cycle. When instantiated with a `length`, `start_date`,
  # `resting_metabolic_rate`, and `weight_loss_goal_in_kg`, it can report the
  # number of days remaining in the current cycle and the number of calories
  # that should be consumed (net) each day.
  class DietPeriod
    extend CachedOutputsWithRecalculation
    include Comparable

    CALORIES_PER_KG = 7_500

    def initialize(length:, start_date:, resting_metabolic_rate:,
                   weight_loss_goal_in_kg:, calendar: Date)
      self.length = length
      self.start_date = start_date
      self.resting_metabolic_rate = resting_metabolic_rate
      self.weight_loss_goal_in_kg = weight_loss_goal_in_kg
      self.calendar = calendar
    end

    def_input :length, validate_with: ->(value) {
      value.kind_of?(Integer) \
        && value > 0
    }

    def_input :start_date, validate_with: ->(value) {
      value.kind_of?(Date)
    }
    alias_method :to_date, :start_date

    def_input :resting_metabolic_rate, validate_with: ->(value) {
      value.kind_of?(Integer) \
        && value > 0
    }

    def_input :weight_loss_goal_in_kg, validate_with: ->(value) {
      value.kind_of?(Numeric)
    }

    def_output :current_day do
      (calendar.today - current_cycle_start_date).to_i
    end

    def_output :days_remaining do
      length - current_day
    end

    def_output :net_calorie_goal do
      rmr_for_period - planned_calorie_deficit
    end

    def succ
      self.clone.tap do |period|
        period.start_date = start_date + length
      end
    end

    def <=>(other)
      start_date <=> other.to_date
    end

    private

    attr_accessor :calendar

    def current_cycle_start_date
      current_cycle.start_date
    end

    def current_cycle
      (self..calendar.today).to_a.last
    end

    def rmr_for_period
      resting_metabolic_rate * length
    end

    def planned_calorie_deficit
      (weight_loss_goal_in_kg * CALORIES_PER_KG).ceil
    end
  end
end
