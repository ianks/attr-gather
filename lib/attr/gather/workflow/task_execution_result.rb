# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # @api private
      TaskExecutionResult = Struct.new(:ran_at, :task, :result) do
        def value!
          result.value!
        end
      end
    end
  end
end
