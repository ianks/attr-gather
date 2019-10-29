# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # A wrapper containing information and results of a task execution
      #
      # # @!attribute [r] started_at
      #     @return [Time] time which the execution occured
      #
      # # @!attribute [r] task
      #     @return [Attr::Gather::Workflow::Task] task that was run
      #
      # # @!attribute [r] result
      #     @return [Concurrent::Promise] the result promise of the the task
      #
      # @api public
      TaskExecutionResult = Struct.new(:task, :result) do
        attr_reader :started_at

        def initialize(*)
          @started_at = Time.now
          super
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
