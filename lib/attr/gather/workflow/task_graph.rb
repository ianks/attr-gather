# frozen_string_literal: true

require 'tsort'

module Attr
  module Gather
    module Workflow
      # @api private
      class TaskGraph
        class UnfinishableError < StandardError; end

        include TSort

        attr_reader :task_list

        def initialize(tasks: [])
          @task_list = tasks.dup
        end

        def <<(task)
          task_list << task
        end

        def each_batch
          return enum_for(:each_batch) unless block_given?

          to_execute = tsort.reverse

          until to_execute.empty?
            batch = to_execute.take_while do |task|
              task.fullfilled_given_remaining_tasks?(to_execute)
            end

            to_execute -= batch

            validate_finishable!(batch, to_execute)

            yield batch
          end
        end

        alias to_a tsort

        def to_h
          task_list.each_with_object({}) do |task, memo|
            memo[task] = all_dependencies_for_task(task)
          end
        end

        private

        def tsort_each_node
          task_list.each { |t| yield t }
        end

        def tsort_each_child(node)
          task_list.each { |t| yield(t) if t.depends_on?(node) }
        end

        def validate_finishable!(batch, to_execute)
          return unless batch.empty? && !to_execute.empty?

          raise UnfinishableError,
                'make sure that no task dependencies can be left unfulfilled'
        end

        def all_dependencies_for_task(input_task)
          task_list.select { |task| input_task.depends_on?(task) }.to_set
        end
      end
    end
  end
end
