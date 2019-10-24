# frozen_string_literal: true

require 'dry/monads/task'
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
            result = Dry::Monads::Task[executor] { task_proc.call(input) }
            TaskExecutionResult.new(task, result)
          end
        end
      end
    end
  end
end
