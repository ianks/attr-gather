# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # @api private
      class Task
        attr_accessor :provider, :depends_on, :name

        def initialize(name:, depends_on: [])
          @name = name
          @depends_on = depends_on
        end

        def depends_on?(other_task)
          depends_on.include?(other_task.name)
        end

        def fullfilled_given_remaining_tasks?(task_list)
          task_list.none? { |list_task| depends_on?(list_task) }
        end
      end
    end
  end
end
