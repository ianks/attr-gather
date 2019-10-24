# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # @api private
      TaskExecutionResult = Struct.new(:task, :result) do
        attr_reader :ran_at

        def initialize(*)
          @ran_at = Time.now
          super
        end

        def value!
          result.value!
        end
      end
    end
  end
end
