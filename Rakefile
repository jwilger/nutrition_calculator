require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cucumber/rake/task"
require "yard"

RSpec::Core::RakeTask.new(:spec)

desc "Run all cucumber features"
task :features => 'features:default'

namespace :features do
  task :default => %w(wip ok)

  Cucumber::Rake::Task.new(:wip) do |t|
    t.cucumber_opts = "-t @wip"
  end

  Cucumber::Rake::Task.new(:ok) do |t|
    t.cucumber_opts = "-t ~@wip -t ~@pending -q --format progress"
  end
end

task :default => %w(spec features)

YARD::Rake::YardocTask.new do |t|
  t.files = %w(lib/**/*.rb - README.md LICENSE.txt)
  t.options = %w(-o doc --protected --hide-api nodoc)
end
