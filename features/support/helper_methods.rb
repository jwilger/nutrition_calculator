require 'nutrition_calculator/calorie_budgeter'

def inputs
  @inputs ||= NutritionCalculator::CalorieBudgeter.new
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
