# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # Module containing graph functionality
      #
      # @api public
      module Graphable
        # Class methods for graph functionality
        module ClassMethods
          # Returns the graph of tasks
          #
          # @return [TaskGraph] the graph
          #
          # @api private
          def tasks
            @tasks ||= TaskGraph.new
          end

          # Returns a graphviz visualization of the workflow
          #
          # @param preview [Boolean] show a preview image of the Workflow
          #
          # @api public
          def to_dot(preview: true)
            tasks.to_dot(preview: preview)
          end
        end

        # Instance methods for graph functionality
        module InstanceMethods
          # Returns a graphviz visualization of the workflow
          #
          # @param preview [Boolean] show a preview image of the Workflow
          #
          # @api public
          def to_dot(preview: true)
            self.class.to_dot(preview: preview)
          end
        end

        def self.included(klass)
          klass.extend(ClassMethods)
          klass.include(InstanceMethods)
        end
      end
    end
  end
end
