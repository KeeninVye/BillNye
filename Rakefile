require "bundler/gem_tasks"
require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Use this to generate simplecov test coverage"
task :coverage do |t|
  ENV["COVERAGE"] = 'true'
  Rake::Task[:spec].execute
end