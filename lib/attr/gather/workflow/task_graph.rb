# frozen_string_literal: true

require 'tsort'
require 'attr/gather/workflow/dot_serializer'

module Attr
  module Gather
    module Workflow
      # @api private
      class TaskGraph
        class UnfinishableError < StandardError; end

        class InvalidTaskDepedencyError < StandardError; end

        include TSort

        attr_reader :tasks_hash

        def initialize(tasks: [])
          @tasks_hash = {}
          tasks.each { |t| self << t }
        end

        def <<(hash)
          name, depends_on = hash.values_at :name, :depends_on
          task = build_task(name, depends_on)
          validate_for_insert!(task)

          registered_tasks.each do |t|
            tasks_hash[t] << task if t.depends_on?(task)
            tasks_hash[t].uniq!
          end

          tasks_hash[task] = all_dependencies_for_task(task)
        end

        def runnable_tasks
          tsort.take_while do |task|
            task.fullfilled_given_remaining_tasks?(registered_tasks)
          end
        end

        def each_batch
          return enum_for(:each_batch) unless block_given?

          to_execute = tsort

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
          tasks_hash
        end

        def to_dot(preview: false)
          serializer = DotSerializer.new(self)
          preview ? serializer.preview : serializer.to_dot
        end

        private

        def build_task(name, depends_on)
          deps = depends_on.map do |dep_name|
            registered_tasks.find do |task|
              task.name == dep_name
            end
          end

          Task.new(name: name, depends_on: deps)
        end

        def tsort_each_child(node, &blk)
          to_h[node].each(&blk)
        end

        def tsort_each_node(&blk)
          to_h.each_key(&blk)
        end

        def validate_finishable!(batch, to_execute)
          return unless batch.empty? && !to_execute.empty?

          # TODO: statically verify this
          raise UnfinishableError, 'task dependencies are not fulfillable'
        end

        def validate_for_insert!(task)
          return if depended_on_tasks_exist?(task)

          raise InvalidTaskDepedencyError,
                "could not find a matching task for #{task.name}"
        end

        def all_dependencies_for_task(input_task)
          registered_tasks.select { |task| input_task.depends_on?(task) }
        end

        def registered_tasks
          tasks_hash.keys
        end

        def depended_on_tasks_exist?(task)
          task.depends_on.all? { |t| registered_tasks.include?(t) }
        end
      end
    end
  end
end
