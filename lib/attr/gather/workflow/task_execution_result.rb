# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # A wrapper containing information and results of a task execution
      #
      # @!attribute [r] started_at
      #   @return [Time] time which the execution occured
      #
      # @!attribute [r] task
      #   @return [Attr::Gather::Workflow::Task] task that was run
      #
      # @!attribute [r] result
      #   @return [Concurrent::Promise] the result promise of the the task
      #
      # @api public
      class TaskExecutionResult
        include Concerns::Identifiable

        attr_reader :task, :result, :started_at, :uuid

        def initialize(task, result, started_at: Time.now, uuid: SecureRandom.uuid) # rubocop:disable Metrics/LineLength
          @task = task
          @result = result
          @started_at = started_at
          @uuid = uuid
        end

        # @!attribute [r] state
        #   @return [:unscheduled, :pending, :processing, :rejected, :fulfilled]
        def state
          result.state
        end

        # Extracts the result, this is an unsafe operation that blocks the
        # operation, and returns either the value or an exception.
        #
        # @note For more information, check out {https://ruby-concurrency.github.io/concurrent-ruby/1.1.5/Concurrent/Concern/Obligation.html#value!-instance_method}
        def value!
          result.value!
        end

        # Chain a new block result to be executed after resolution
        #
        # @return [TaskExecutionResult] the new task execution result
        # @yield The block operation to be performed asynchronously.
        def then(*args, &block)
          new_result = result.then(*args, &block)
          self.class.new(task, new_result, started_at: @started_at, uuid: @uuid)
        end

        # Catch an async exception when a failure occurs
        #
        # @return [TaskExecutionResult] the new task execution result
        # @yield The block operation to be performed asynchronously.
        def catch(*args, &block)
          new_result = result.catch(*args, &block)
          self.class.new(task, new_result, started_at: @started_at, uuid: @uuid)
        end

        # Executes a block after the result is fulfilled
        # Represents the TaskExecutionResult as a hash
        #
        # @return [Hash]
        def as_json
          value = result.value

          { started_at: started_at,
            task: task.as_json,
            state: state,
            value: value }
        end
      end
    end
  end
end
