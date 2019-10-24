# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # @api private
      class TaskExecutor
        include Dry::Monads[:task]

        attr_accessor :batch, :container

        def initialize(batch, container:)
          @batch = batch
          @container = container
        end

        def call(input)
          results = batch.map do |task|
            task_proc = container.resolve(task.name)
            Task { task_proc.call(input) }
          end

          results.map(&:value!)
        end
      end
    end
  end
end
