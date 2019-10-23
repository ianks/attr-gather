# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # @api private
      class Task
        attr_accessor :provider, :depends_on, :name

        def initialize(name:, depends_on: [])
          @name = name
          @depends_on = depends_on
        end
      end
    end
  end
end
