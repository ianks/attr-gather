# frozen_string_literal: true

require 'attr/gather/workflow/task'
require 'attr/gather/workflow/task_graph'
require 'attr/gather/workflow/dsl'
require 'attr/gather/workflow/callable'

module Attr
  module Gather
    # Main mixin for functionality. Adds the ability to turn a class into a
    # workflow.
    module Workflow
      def self.included(klass)
        klass.extend(DSL)
        klass.include(Callable)
      end
    end
  end
end
