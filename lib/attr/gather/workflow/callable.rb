# frozen_string_literal: true

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
        #   enhancer.call(user_id: 1).value! # => {user_id: 1, email: 't@t.co}
        #
        # @param input [Hash]
        #
        # @return [Concurrent::Promise<Hash>]
        #
        # @note For more information, check out {https://dry-rb.org/gems/dry-monads/1.0/result}
        #
        # @api public
        def call(input)
          task_promises = {}

          final_results = self.class.tasks.to_a.map do |task|
            task_promises[task] = execute_task(input, task, task_promises)
          end

          Concurrent::Promise.zip(*final_results).then do |results|
            aggregator.call(input, results)
          end
        end

        private

        # Executes a batch of tasks
        #
        # @return [Array<TaskExecutionResult>]
        #
        # @api private
        def execute_task(initial_input, task, task_promises)
          task_proc = container.resolve(task.name)
          dep_promises = task.depends_on.map { |t| task_promises[t] }
          input_promise = Concurrent::Promise.zip(*dep_promises)

          input_promise.then do |results|
            dep_input = aggregator.call(initial_input, results)
            task_proc.call(dep_input)
          end
        end

        # @api private
        def container
          self.class.container
        end

        # @api private
        def aggregator
          return @aggregator if defined?(@aggregator) && !@aggregator.nil?

          @aggregator = self.class.aggregator
          @aggregator.filter ||= filter if @aggregator.respond_to?(:filter=)

          @aggregator
        end

        # @api private
        def filter
          self.class.filter
        end
      end
    end
  end
end
