# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task :e2e_tests do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/e2e/*_spec.rb'
  end
  Rake::Task['spec'].execute
end

task :unit_tests do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/evervault_spec.rb, spec/evervault/**/*_spec.rb'
  end
  Rake::Task['spec'].execute
end

task :default do
  RSpec::Core::RakeTask.new(:spec)
  Rake::Task['spec'].execute
end
