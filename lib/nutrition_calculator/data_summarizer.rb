require 'date'

module NutritionCalculator
  class DataSummarizer
    SUNDAY = 7
    MONDAY = 1

    def initialize(source_data:, calendar: Date)
      self.source_data = source_data
      self.calendar = calendar
    end

    def prior_days_net_calories
      return 0 if current_day == MONDAY
      values = (1...current_day).map { |day| net_calories_for_day(day) }
      values.reduce { |weekly_net, daily_net| weekly_net + daily_net }
    end

    def calories_consumed_today
      source_data_for_day(current_day)['calories_consumed']
    end

    def calories_burned_today
      source_data_for_day(current_day)['calories_burned']
    end

    # TODO: this probably isn't the right place to put this, since it looks like
    # it does need to be exposed to the CalorieBudgeter as well. Still, this is
    # better than having it live in the CLI script itself for now.
    def current_day
      day = calendar.today.wday
      day = SUNDAY if day < MONDAY
      day
    end

    private
    attr_accessor :source_data, :calendar

    def net_calories_for_day(day)
      data = source_data_for_day(day)
      data['calories_consumed'] - data['calories_burned']
    end

    def source_data_for_day(day)
      source_data.fetch(day) do
        {'calories_consumed' => 0, 'calories_burned' => 0}
      end
    end
  end
end
