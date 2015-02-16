require 'spec_helper'
require 'nutrition_calculator/diet_period'

describe NutritionCalculator::DietPeriod do
  CALORIES_PER_KG = 7_500

  subject {
    described_class.new(length: period_length, start_date: start_date,
                        resting_metabolic_rate: rmr,
                        weight_loss_goal_in_kg: loss_goal,
                        calendar: calendar)
  }

  let(:calendar) { double(:calendar, today: current_date) }

  let(:rmr) { 2000 }

  let(:expected_net_calorie_goal) {
    (rmr * period_length) - (loss_goal * CALORIES_PER_KG)
  }

  let(:start_date) { Date.new(2015,2,16) }
  let(:current_date) { Date.new(2015,2,16) }

  context 'when the period is 7 days long' do
    let(:period_length) { 7 }
    let(:loss_goal) { 0.5 }

    it 'calculates the calorie budget for the entire period' do
      expect(subject.net_calorie_goal).to eq expected_net_calorie_goal
    end

    context 'it is the first day of the first cycle of the period' do
      let(:current_date) { Date.new(2015,2,16) }

      it 'reports that today is the 0th day of the period' do
        expect(subject.current_day).to eq 0
      end

      it 'reports that there are 7 days remaining in the period' do
        expect(subject.days_remaining).to eq 7
      end
    end

    context 'it is the last day of the first cycle of the period' do
      let(:current_date) { Date.new(2015,2,22) }

      it 'reports that today is the 6th day of the period' do
        expect(subject.current_day).to eq 6
      end

      it 'reports that there is 1 day remaining in the period' do
        expect(subject.days_remaining).to eq 1
      end
    end

    context 'it is the first day of the third cycle of the period' do
      let(:current_date) { Date.new(2015,3,2) }

      it 'reports that today is the 0th day of the period' do
        expect(subject.current_day).to eq 0
      end

      it 'reports that there are 7 days remaining in the period' do
        expect(subject.days_remaining).to eq 7
      end
    end

    context 'it is the last day of the first cycle of the period' do
      let(:current_date) { Date.new(2015,3,8) }

      it 'reports that today is the 6th day of the period' do
        expect(subject.current_day).to eq 6
      end

      it 'reports that there is 1 day remaining in the period' do
        expect(subject.days_remaining).to eq 1
      end
    end
  end

  context 'when the period is 10 days long' do
    let(:period_length) { 10 }
    let(:loss_goal) { 0.5 }

    it 'calculates the calorie budget for the entire period' do
      expect(subject.net_calorie_goal).to eq expected_net_calorie_goal
    end

    context 'it is the first day of the first cycle of the period' do
      let(:current_date) { Date.new(2015,2,16) }

      it 'reports that today is the 0th day of the period' do
        expect(subject.current_day).to eq 0
      end

      it 'reports that there are 10 days remaining in the period' do
        expect(subject.days_remaining).to eq 10
      end
    end

    context 'it is the last day of the first cycle of the period' do
      let(:current_date) { Date.new(2015,2,25) }

      it 'reports that today is the 9th day of the period' do
        expect(subject.current_day).to eq 9
      end

      it 'reports that there is 1 day remaining in the period' do
        expect(subject.days_remaining).to eq 1
      end
    end

    context 'it is the first day of the third cycle of the period' do
      let(:current_date) { Date.new(2015,3,8) }

      it 'reports that today is the 0th day of the period' do
        expect(subject.current_day).to eq 0
      end

      it 'reports that there are 7 days remaining in the period' do
        expect(subject.days_remaining).to eq 10
      end
    end

    context 'it is the last day of the third cycle of the period' do
      let(:current_date) { Date.new(2015,3,17) }

      it 'reports that today is the 6th day of the period' do
        expect(subject.current_day).to eq 9
      end

      it 'reports that there is 1 day remaining in the period' do
        expect(subject.days_remaining).to eq 1
      end
    end
  end
end
