# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:lint)
YARD::Rake::YardocTask.new(:doc)

task default: %i[spec lint]

namespace :examples do
  desc 'Run all examples'
  task :run do
    Dir['examples/*.rb'].each do |filename|
      system "ruby #{filename}"
    end
  end
end
