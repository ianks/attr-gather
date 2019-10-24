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

        # TODO: factor our
        def aggregator
          lambda do |input, result|
            result.reduce(input.dup, &:merge)
          end
        end

        def call(input)
          result_attrs = self.class.tasks.each_batch.reduce(input.dup) do |memo, batch|
            executor = TaskExecutor.new(batch, container: self.class.container)
            result = executor.call(memo)
            aggregator.call(memo, result)
          end

          Success(result_attrs)
        end
      end
    end
  end
end
