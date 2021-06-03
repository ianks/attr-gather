# frozen_string_literal: true

require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  warn 'Could not load rspec rake task'
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:lint)
rescue LoadError
  warn 'Could not load rubocop rake task'
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:doc)
rescue LoadError
  warn 'Could not load yarddoc rake task'
end

task default: %i[spec lint doc]

namespace :examples do
  desc 'Run all examples'
  task :run do
    Dir['examples/*.rb'].each do |filename|
      system "ruby #{filename}"
    end
  end
end
