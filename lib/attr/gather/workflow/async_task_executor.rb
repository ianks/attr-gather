# frozen_string_literal: true

require 'attr/gather/workflow/task_executor'

module Attr
  module Gather
    module Workflow
      # @api private
      class AsyncTaskExecutor < TaskExecutor
        def initialize(*)
          super
          @executor = :io
        end
      end
    end
  end
end
