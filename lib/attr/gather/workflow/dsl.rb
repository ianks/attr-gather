# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # DSL for configuring a workflow
      #
      # @api private
      module DSL
        def tasks
          @tasks ||= TaskGraph.new
        end

        def task(task_name)
          task = Task.new(name: task_name)
          yield task
          tasks << task
        end

        def container(cont = nil)
          @container = cont if cont
          @container
        end
      end
    end
  end
end
