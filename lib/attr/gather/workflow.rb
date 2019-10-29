# frozen_string_literal: true

require 'attr/gather/workflow/task'
require 'attr/gather/workflow/task_graph'
require 'attr/gather/workflow/dsl'
require 'attr/gather/workflow/callable'
require 'attr/gather/workflow/graphable'

module Attr
  module Gather
    # Main mixin for functionality. Adds the ability to turn a class into a
    # workflow.
    module Workflow
      # @!parse extend DSL
      # @!parse include Callable
      # @!parse extend Graphable::ClassMethods
      # @!parse include Graphable::InstanceMethods

      def self.included(klass)
        klass.extend(DSL)
        klass.include(Callable)
        klass.include(Graphable)
      end
    end
  end
end
