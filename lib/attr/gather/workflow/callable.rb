# frozen_string_literal: true

require 'dry/monads'
require 'attr/gather/workflow/task_executor'
require 'attr/gather/workflow/async_task_executor'

module Attr
  module Gather
    module Workflow
      # @api private
      module Callable
        # Execute a workflow
        #
        # When executing the workflow, tasks are processed in dependant order,
        # with the outputs of each batch being fed as inputs to the next batch.
        # This means the you can enhance the data as the task moves through a
        # workflow, so later tasks can use the enhanced input data.
        #
        # @example
        #   enhancer = MyEnhancingWorkflow.new
        #   enhancer.call(user_id: 1) # => Success({user_id: 1, email: 't@t.co})
        #
        # @param input [Hash]
        #
        # @return [Dry::Monads::Result]
        #
        # @note For more information, check out {https://dry-rb.org/gems/dry-monads/1.0/result}
        #
        # @api public
        def call(input)
          final_results = []

          each_task_batch.reduce(input.dup) do |aggregated_input, batch|
            executor_results = execute_batch(aggregated_input, batch)
            final_results << executor_results
            aggregator.call(aggregated_input, executor_results).value!
          end

          aggregator.call(input.dup, final_results.flatten(1))
        end

        private

        # Enumator for task batches
        #
        # @return [Enumerator]
        #
        # @api private
        def each_task_batch
          self.class.tasks.each_batch
        end

        # Executes a batch of tasks
        #
        # @return [Array<TaskExecutionResult>]
        #
        # @api private
        def execute_batch(aggregated_input, batch)
          executor = AsyncTaskExecutor.new(batch, container: container)
          executor.call(aggregated_input)
        end

        # @api private
        def container
          self.class.container
        end

        # @api private
        def aggregator
          self.class.aggregator
        end
      end
    end
  end
end
