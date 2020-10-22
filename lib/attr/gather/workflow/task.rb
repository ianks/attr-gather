# frozen_string_literal: true

require 'dry-equalizer'

module Attr
  module Gather
    module Workflow
      # @api private
      class Task
        include Dry::Equalizer(:name, :depends_on)

        attr_accessor :name, :depends_on

        def initialize(name:, depends_on: [])
          @name = name
          @depends_on = depends_on
        end

        def depends_on?(other_task)
          depends_on.include?(other_task)
        end

        def fullfilled_given_remaining_tasks?(task_list)
          task_list.none? { |list_task| depends_on?(list_task) }
        end

        def as_json
          { name: name, depends_on: depends_on }
        end
      end
    end
  end
end
