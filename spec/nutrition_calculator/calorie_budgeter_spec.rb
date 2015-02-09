require 'spec_helper'
require 'logger'
require 'nutrition_calculator/calorie_budgeter'

describe NutritionCalculator::CalorieBudgeter do
  # Uncomment the following line if you need debugging output
  # subject { described_class.new(logger: Logger.new(STDERR)) }

  describe '#net_calorie_consumption' do
    it 'is the number of calories consumed less any calories burned via exercise' do
      subject.calories_consumed = 100
      subject.calories_burned = 10
      expect(subject.net_calorie_consumption).to eq 90
    end
  end

  describe '#remaining_calories_this_week' do
    it 'is the weekly calorie goal less net calories from previous days' do
      subject.weekly_calorie_goal = 10_000
      subject.prior_days_calories = 1_000
      expect(subject.remaining_calories_this_week).to eq 9000
    end
  end

  describe '#daily_calorie_goal' do
    let(:days_left) { 8 - day }
    let(:weekly_goal) { 10_000 }

    before(:each) do
      subject.current_day_of_week = day
      subject.weekly_calorie_goal = weekly_goal
      subject.prior_days_calories = weekly_consumed
    end

    shared_examples_for 'it calculates the daily calorie goal' do
      it 'is the number of calories remaining for the week divided by the remaining days in the week' do
        expected = ((weekly_goal - weekly_consumed).to_f / days_left).round
        expect(subject.daily_calorie_goal).to eq expected
      end
    end

    (1..7).each do |day_num|
      context "on day #{day_num}" do
        let(:day) { day_num }
        let(:weekly_consumed) { day_num * 10 }
        it_behaves_like 'it calculates the daily calorie goal'
      end
    end
  end

  describe '#target_daily_calorie_consumption' do
    before(:each) do
      subject.current_day_of_week = 1
      subject.prior_days_calories = 0
      subject.resting_metabolic_rate = 2_000
    end

    context 'when the daily calorie goal is the same as the RMR' do
      before(:each) do
        subject.weekly_calorie_goal = 14_000
      end

      context 'when no calories have been burned via exercise' do
        before(:each) do
          subject.calories_burned = 0
        end

        it 'is equal to the resting metabolic rate' do
          expect(subject.target_daily_calorie_consumption).to eq 2_000
        end
      end

      context 'when calories have been burned via exercise' do
        before(:each) do
          subject.calories_burned = 100
        end

        it 'is equal to the resting metabolic rate plus exercise calories' do
          expect(subject.target_daily_calorie_consumption).to eq 2_100
        end
      end
    end

    context 'when the daily calorie goal is lower than the RMR' do
      before(:each) do
        subject.weekly_calorie_goal = 10_500
      end

      context 'when no calories have been burned via exercise' do
        before(:each) do
          subject.calories_burned = 0
        end

        it 'is equal to the resting metabolic rate' do
          expect(subject.target_daily_calorie_consumption).to eq 2_000
        end
      end

      context 'when calories burned are less than difference between goal and RMR' do
        before(:each) do
          subject.calories_burned = 100
        end

        it 'is equal to the resting metabolic rate' do
          expect(subject.target_daily_calorie_consumption).to eq 2_000
        end
      end

      context 'when calories burned are equal to the difference between goal and RMR' do
        before(:each) do
          subject.calories_burned = 500
        end

        it 'is equal to the resting metabolic rate' do
          expect(subject.target_daily_calorie_consumption).to eq 2_000
        end
      end

      context 'when calories burned are greater than the difference between goal and RMR' do
        before(:each) do
          subject.calories_burned = 501
        end

        it 'is equal to the daily goal plus calories burned' do
          expect(subject.target_daily_calorie_consumption).to eq 2_001
        end
      end
    end

    context 'when the daily calorie goal is higher than the RMR' do
      before(:each) do
        subject.weekly_calorie_goal = 17_500
      end

      context 'when no calories have been burned via exercise' do
        before(:each) do
          subject.calories_burned = 0
        end

        it 'is equal to the daily calorie goal rate' do
          expect(subject.target_daily_calorie_consumption).to eq 2_500 
        end
      end

      context 'when any calories have been burned via exercise' do
        before(:each) do
          subject.calories_burned = 1
        end

        it 'is equal to the daily goal plus calories burned' do
          expect(subject.target_daily_calorie_consumption).to eq 2_501
        end
      end
    end
  end

  describe '#remaining_to_target' do
    before(:each) do
      subject.resting_metabolic_rate = 2_000
      subject.weekly_calorie_goal = 14_000
      subject.current_day_of_week = 1
      subject.prior_days_calories = 0
      subject.calories_burned = 0
    end

    it 'is equal to the target daily calorie consumption less any calories already consumed' do
      subject.calories_consumed = 500
      expect(subject.remaining_to_target).to eq 1_500
    end

    it 'can be negative' do
      subject.calories_consumed = 2_001
      expect(subject.remaining_to_target).to eq -1
    end
  end

  describe 'calories_remaining' do
    before(:each) do
      subject.resting_metabolic_rate = 2_000
      subject.weekly_calorie_goal = 14_000
      subject.current_day_of_week = 1
      subject.prior_days_calories = 0
      subject.calories_burned = 0
    end

    it 'is usually equal to the calories remaining to target' do
      subject.calories_consumed = 500
      expect(subject.calories_remaining).to eq 1_500
    end

    it 'will not be less than zero' do
      subject.calories_consumed = 2_001
      expect(subject.calories_remaining).to eq 0
    end
  end

  describe '#predicted_calorie_consumption' do
    before(:each) do
      subject.current_day_of_week = 1
      subject.prior_days_calories = 0
      subject.resting_metabolic_rate = 2_000
      subject.weekly_calorie_goal = 14_000
      subject.calories_burned = 0
    end

    context 'when net calorie consumption is less than the target daily consumption' do
      before(:each) do
        subject.calories_consumed = 1_999
      end

      it 'is equal to the target daily consumption' do
        expect(subject.predicted_calorie_consumption).to eq 2_000
      end
    end

    context 'when net calorie consumption is equal to the target daily consumption' do
      before(:each) do
        subject.calories_consumed = 2_000
      end

      it 'is equal to the target daily consumption' do
        expect(subject.predicted_calorie_consumption).to eq 2_000
      end
    end

    context 'when net calorie consumption is greater than the target daily consumption' do
      before(:each) do
        subject.calories_consumed = 2_001
      end

      it 'is equal to the net consumption' do
        expect(subject.predicted_calorie_consumption).to eq 2_001
      end
    end
  end
end
