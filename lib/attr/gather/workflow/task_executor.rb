# frozen_string_literal: true

require 'concurrent'
require 'attr/gather/workflow/task_execution_result'

module Attr
  module Gather
    module Workflow
      # @api private
      class TaskExecutor
        attr_reader :batch, :container, :executor

        def initialize(batch, container:)
          @batch = batch
          @container = container
          @executor = :immediate
        end

        def call(input)
          batch.map do |task|
            task_proc = container.resolve(task.name)
            result = Concurrent::Promise.execute(executor: executor) do
              task_proc.call(input)
            end
            TaskExecutionResult.new(task, result)
          end
        end
      end
    end
  end
end
