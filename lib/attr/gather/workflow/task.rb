# frozen_string_literal: true

require 'dry-equalizer'

module Attr
  module Gather
    module Workflow
      # @api private
      class Task
        send :include, Dry::Equalizer(:name, :depends_on)

        attr_accessor :name, :depends_on

        # Initialize a new DeepMerge aggregator
        #
        # @param name [String] name of the task
        # @param depends_on [Array<Task>] tasks which are needed to before running
        #
        # @api private
        def initialize(name:, depends_on: [])
          @name = name
          @depends_on = depends_on
        end

        # Check if this task depends on a given task
        #
        # @param other_task [Task] task to check
        def depends_on?(other_task)
          depends_on.include?(other_task)
        end

        def fullfilled_given_remaining_tasks?(task_list)
          task_list.none? { |list_task| depends_on?(list_task) }
        end

        def as_json
          { name: name, depends_on: depends_on }
        end
      end
    end
  end
end
