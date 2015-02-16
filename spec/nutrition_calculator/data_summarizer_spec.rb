require 'spec_helper'
require 'nutrition_calculator/data_summarizer'

describe NutritionCalculator::DataSummarizer do
  let(:source_data) {{
    1 => {
      'calories_consumed' => 1000,
      'calories_burned' => 500
    },
    2 => {
      'calories_consumed' => 1001,
      'calories_burned' => 500
    },
    3 => {
      'calories_consumed' => 1000,
      'calories_burned' => 501
    },
    4 => {
      'calories_consumed' => 1002,
      'calories_burned' => 500
    },
    5 => {
      'calories_consumed' => 1000,
      'calories_burned' => 502
    },
    6 => {
      'calories_consumed' => 1003,
      'calories_burned' => 500
    },
    7 => {
      'calories_consumed' => 1000,
      'calories_burned' => 503
    },
  }}

  let(:calendar) { double(:calendar, today: today) }

  subject { described_class.new(source_data: source_data, calendar: calendar) }

  context "on day 1" do
    let(:today) { Date.new(2015,2,16) }

    it 'reports prior_days_net_calories as 0' do
      expect(subject.prior_days_net_calories).to eq 0
    end

    it 'reports calories burned today' do
      expect(subject.calories_burned_today).to eq 500
    end

    it 'reports calories consumed today' do
      expect(subject.calories_consumed_today).to eq 1000
    end

    it 'reports that the current day number is 1' do
      expect(subject.current_day).to eq 1
    end
  end

  context "on day 7" do
    let(:today) { Date.new(2015,2,22) }

    it 'reports prior_days_net_calories as the sum of calories consumed less the sum of calories burned' do
      expect(subject.prior_days_net_calories).to eq 3_003
    end

    it 'reports calories burned today' do
      expect(subject.calories_burned_today).to eq 503
    end

    it 'reports calories consumed today' do
      expect(subject.calories_consumed_today).to eq 1000
    end

    it 'reports that the current day number is 7' do
      expect(subject.current_day).to eq 7
    end
  end
end
