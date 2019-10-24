# frozen_string_literal: true

require 'dry/monads'
require 'attr/gather/workflow/task_executor'
require 'attr/gather/workflow/async_task_executor'

module Attr
  module Gather
    module Workflow
      # @api private
      module Callable
        def self.included(klass)
          klass.include Dry::Monads[:result]
        end

        # TODO: factor out
        def aggregator
          lambda do |input, results|
            results.reduce(input.dup) { |memo, res| memo.merge(res.value!) }
          end
        end

        def call(input)
          result_attrs = each_task_batch.reduce(input.dup) do |memo, batch|
            executor = AsyncTaskExecutor.new(batch, container: container)
            result = executor.call(memo)
            aggregator.call(memo, result)
          end

          Success(result_attrs)
        end

        private

        def container
          self.class.container
        end

        def each_task_batch
          self.class.tasks.each_batch
        end
      end
    end
  end
end
