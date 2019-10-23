# frozen_string_literal: true

require 'dry/monads'
require 'attr/gather/workflow/task_executor'

module Attr
  module Gather
    module Workflow
      # @api private
      module Callable
        def self.included(klass)
          klass.include Dry::Monads[:result]
        end

        def call(input)
          result_attrs = self.class.tasks.reduce(input.dup) do |memo, task|
            executor = TaskExecutor.new(task, container: self.class.container)
            task_result = executor.call(memo)
            memo.merge(task_result)
          end

          Success(result_attrs)
        end
      end
    end
  end
end
