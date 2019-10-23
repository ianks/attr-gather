# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # @api private
      class TaskExecutor
        include Dry::Monads[:task]

        attr_accessor :task, :container

        def initialize(task, container:)
          @task = task
          @container = container
        end

        def call(input)
          task_proc = container.resolve(task.name)
          task_proc.call(input)
        end
      end
    end
  end
end
