# frozen_string_literal: true

require 'tempfile'

module Attr
  module Gather
    module Workflow
      # @api private
      class DotSerializer
        def initialize(task_graph)
          @task_graph = task_graph
        end

        def to_dot
          lines = @task_graph.tsort.map { |t| serialize_row(t) }
          joined_lines = lines.flatten.map { |l| "  #{l}" }.join("\n").strip

          <<~DOT
            digraph TaskGraph {
              #{joined_lines}
            }
          DOT
        end

        def preview
          Tempfile.open do |tf|
            IO.popen("dot -Tsvg -o #{tf.path}", 'w') { |p| p.write(to_dot) }
            `xdg-open #{tf.path}`
          end
        end

        private

        def serialize_row(task)
          row = all_dependants_for_task(task).map { |dt| [task, dt] }
          lines = row.map { |item| item.map(&:name).join(' -> ') + ';' }
          lines
        end

        def all_dependants_for_task(input_task)
          @task_graph.to_h.keys.select { |task| task.depends_on?(input_task) }
        end
      end
    end
  end
end
