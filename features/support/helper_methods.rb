require 'ostruct'
require 'nutrition_calculator/remaining_daily_calories_calculator'

def inputs
  @inputs ||= NutritionCalculator::RemainingDailyCaloriesCalculator.new
end

def calculate_remaining_calories
  # this is a noop, because the calculator calculates the data upon request of
  # its attributes
end

def outputs
  inputs
end

def logger
  Logger.new(STDERR)
end
