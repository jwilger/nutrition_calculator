module NutritionCalculator
  class DataSummarizer
    def initialize(source_data:, diet_period:)
      self.source_data = source_data
      self.diet_period = diet_period
    end

    def prior_days_net_calories
      return 0 if current_day == 0
      values = (0...current_day).map { |day|
        diet_day(day).net_calories
      }
      values.reduce { |weekly_net, daily_net| weekly_net + daily_net }
    end

    def calories_consumed_today
      source_data_for_day(current_day)['calories_consumed']
    end

    def calories_burned_today
      source_data_for_day(current_day)['calories_burned']
    end

    private
    attr_accessor :source_data, :diet_period

    def current_day
      diet_period.current_day
    end

    def diet_day(day)
      DietDay.new(source_data_for_day(day))
    end

    def source_data_for_day(day)
      source_data.fetch(day) do
        {'calories_consumed' => 0, 'calories_burned' => 0}
      end
    end

    # Represent the calories consumed/burned for a day
    class DietDay
      attr_accessor :calories_consumed, :calories_burned

      def initialize(data)
        self.calories_consumed = data['calories_consumed']
        self.calories_burned = data['calories_burned']
        freeze
      end

      def net_calories
        calories_consumed - calories_burned
      end
    end
    private_constant DietDay
  end
end
