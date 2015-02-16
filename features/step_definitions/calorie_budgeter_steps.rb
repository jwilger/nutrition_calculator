Given(/^my RMR is (\d+) calories per day$/) do |rmr|
  inputs.resting_metabolic_rate = rmr.to_i
end

Given(/^my weekly calorie goal is (\d+) calories$/) do |cals|
  inputs.weekly_calorie_goal = cals.to_i
end

Given(/^I have consumed (\d+) net calories on prior days this week$/) do |cals|
  inputs.prior_days_calories = cals.to_i
end

Given(/^it is the (\d+)(st|nd|rd|th) day of the week$/) do |day, _|
  day = day.to_i
  inputs.num_days_to_budget = 8 - day
end

Given(/^I have consumed (\d+) calories today$/) do |cals|
  inputs.calories_consumed = cals.to_i
end

Given(/^I have burned (\d+) calories with exercise today$/) do |cals|
  inputs.calories_burned = cals.to_i
end

When(/^I calculate my remaining calories for the day$/) do
  calculate_remaining_calories
end

Then(/^I see that my net calorie consumption for the day is (\-?\d+)$/) do |cals|
  expect(outputs.net_calorie_consumption).to eq cals.to_i
end

Then(/^I see that I should consume (\d+) more calories today$/) do |cals|
  expect(outputs.calories_remaining).to eq cals.to_i
end

Then(/^I see that I should burn (\d+) more calories by exercising today$/) do |cals|
  expect(outputs.exercise_calories_remaining).to eq cals.to_i
end
