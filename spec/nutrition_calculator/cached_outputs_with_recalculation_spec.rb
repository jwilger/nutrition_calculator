require 'spec_helper'
require 'nutrition_calculator/cached_outputs_with_recalculation'

describe NutritionCalculator::CachedOutputsWithRecalculation do
  subject {
    klass = Class.new do
      extend NutritionCalculator::CachedOutputsWithRecalculation

      def_input :foo

      def_output :baz do
        foo.bar
      end
    end

    klass.new
  }

  let(:foo_value) { double('FooValue', bar: 'baz') }

  it 'creates attr_accessors for inputs' do
    subject.foo = :bar
    expect(subject.foo).to eq :bar
  end

  it "complains when asked for the value of an input that was not provided" do
    expect{subject.foo}.to \
      raise_error(RuntimeError, "Required input missing: `foo`.")
  end

  it 'creates attr_readers for outputs' do
    subject.foo = foo_value
    expect(subject.baz).to eq 'baz'
  end

  it 'caches the calculated values for output' do
    subject.foo = foo_value
    expect(foo_value).to receive(:bar).once.and_return('baz')
    2.times do
      subject.baz
    end
  end

  it 'clears cached calculations when inputs are changed' do
    expect(foo_value).to receive(:bar).twice.and_return('baz')
    2.times do
      subject.foo = foo_value
      subject.baz
    end
  end
end
