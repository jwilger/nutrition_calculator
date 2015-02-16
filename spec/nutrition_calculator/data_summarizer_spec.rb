require 'spec_helper'
require 'nutrition_calculator/data_summarizer'

describe NutritionCalculator::DataSummarizer do
  let(:source_data) {{
    0 => {
      'calories_consumed' => 1000,
      'calories_burned' => 500
    },
    1 => {
      'calories_consumed' => 1001,
      'calories_burned' => 500
    },
    2 => {
      'calories_consumed' => 1000,
      'calories_burned' => 501
    },
    3 => {
      'calories_consumed' => 1002,
      'calories_burned' => 500
    },
    4 => {
      'calories_consumed' => 1000,
      'calories_burned' => 502
    },
    5 => {
      'calories_consumed' => 1003,
      'calories_burned' => 500
    },
    6 => {
      'calories_consumed' => 1000,
      'calories_burned' => 503
    },
  }}

  let(:diet_period) { double(:diet_period, current_day: current_day) }

  subject {
    described_class.new(source_data: source_data, diet_period: diet_period)
  }

  context "on day 0" do
    let(:current_day) { 0 }

    it 'reports prior_days_net_calories as 0' do
      expect(subject.prior_days_net_calories).to eq 0
    end

    it 'reports calories burned today' do
      expect(subject.calories_burned_today).to eq 500
    end

    it 'reports calories consumed today' do
      expect(subject.calories_consumed_today).to eq 1000
    end
  end

  context "on day 6" do
    let(:current_day) { 6 }

    it 'reports prior_days_net_calories as the sum of calories consumed less the sum of calories burned' do
      expect(subject.prior_days_net_calories).to eq 3_003
    end

    it 'reports calories burned today' do
      expect(subject.calories_burned_today).to eq 503
    end

    it 'reports calories consumed today' do
      expect(subject.calories_consumed_today).to eq 1000
    end
  end
end
