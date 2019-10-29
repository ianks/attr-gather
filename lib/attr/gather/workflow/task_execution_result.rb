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
      #     @return [Dry::Monad::Task] a monad wrapping the state of the task
      #
      # @api public
      TaskExecutionResult = Struct.new(:task, :result) do
        attr_reader :started_at

        def initialize(*)
          @started_at = Time.now
          super
        end

        # Extracts the result, this is an unsafe operation that blocks the
        # operation, and returns either the value or an exception.
        #
        # @note For more information, check out {https://dry-rb.org/gems/dry-monads/1.0/task/#extracting-result}
        def value!
          result.value!
        end
      end
    end
  end
end
