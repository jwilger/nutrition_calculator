require 'date'

module NutritionCalculator
  class DietPeriod
    include Comparable

    attr_accessor :length, :start_date, :resting_metabolic_rate,
      :weight_loss_goal_in_kg

    alias_method :to_date, :start_date

    def initialize(length:, start_date:, resting_metabolic_rate:,
                   weight_loss_goal_in_kg:, calendar: Date)
      self.length = length
      self.start_date = start_date
      self.resting_metabolic_rate = resting_metabolic_rate
      self.weight_loss_goal_in_kg = weight_loss_goal_in_kg
      self.calendar = calendar
    end

    def current_day
      (calendar.today - current_cycle_start_date).to_i
    end

    def days_remaining
      length - current_day
    end

    def net_calorie_goal
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
      weight_loss_goal_in_kg * CALORIES_PER_KG
    end
  end
end
