# frozen_string_literal: true

require 'dry/monads'

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
            task = fetch_task_by_name(task.name)
            task_result = task.call(memo)
            memo.merge(task_result)
          end

          Success(result_attrs)
        end

        private

        def fetch_task_by_name(name)
          self.class.container.resolve(name)
        end
      end
    end
  end
end
