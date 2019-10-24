# frozen_string_literal: true

require 'dry/monads/task'

module Attr
  module Gather
    module Workflow
      # @api private
      class TaskExecutor
        attr_reader :batch, :container, :executor

        def initialize(batch, container:)
          @batch = batch
          @container = container
          @executor = :immediate
        end

        def call(input)
          results = batch.map do |task|
            task_proc = container.resolve(task.name)
            Dry::Monads::Task[executor] { task_proc.call(input) }
          end

          # TODO: implement error handling
          results.map(&:value!)
        end
      end
    end
  end
end
