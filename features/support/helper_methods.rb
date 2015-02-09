require 'nutrition_calculator/calorie_budgeter'

def inputs
  @inputs ||= NutritionCalculator::CalorieBudgeter.new
end

def calculate_remaining_calories
  # Uncomment the following line if you need debugging output
  # inputs.logger = logger
end

def outputs
  inputs
end

def logger
  Logger.new(STDERR)
end
