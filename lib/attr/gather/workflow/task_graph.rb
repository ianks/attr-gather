# frozen_string_literal: true

require 'tsort'

module Attr
  module Gather
    module Workflow
      # @api private
      class TaskGraph
        include TSort

        def initialize(tasks: [])
          @tasks = tasks
        end

        def <<(task)
          @tasks << task
        end

        alias each tsort_each

        alias to_a tsort

        private

        def tsort_each_node
          @tasks.each { |t| yield t }
        end

        def tsort_each_child(node)
          @tasks.each do |t|
            yield(t) if t.depends_on.include?(node.name)
          end
        end
      end
    end
  end
end
