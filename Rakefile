require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cucumber/rake/task"

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

