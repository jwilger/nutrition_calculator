# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nutrition_calculator/version'

Gem::Specification.new do |spec|
  spec.name          = "nutrition_calculator"
  spec.version       = NutritionCalculator::VERSION
  spec.authors       = ["John Wilger"]
  spec.email         = ["johnwilger@gmail.com"]
  spec.summary       = %q{Nutrition calculators for diet management}
  spec.description   = %q{
    NutritionCalculator provides a set of core libraries to help track a
    person's individual nutritional goals. It is meant to aid in both
    weight-management and monitoring the nutritional balance of a diet.
  }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2.0"
  spec.add_development_dependency "cucumber", "~> 1.3.0"
  spec.add_development_dependency "reek"
  spec.add_development_dependency "yard"
end
