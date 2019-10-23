# frozen_string_literal: true

require 'attr/gather/workflow/task'
require 'attr/gather/workflow/task_graph'

module Attr
  module Gather
    module Workflow
      RSpec.describe TaskGraph do
        it 'sorts tasks topologically' do
          t_one = Task.new(name: :one, depends_on: [])
          t_two = Task.new(name: :two, depends_on: [:one])
          t_three = Task.new(name: :three, depends_on: [:two])
          t_four = Task.new(name: :four, depends_on: [:three])

          graph = described_class.new(tasks: [t_one, t_four, t_three, t_two])
          serialized = graph.to_a

          expect(serialized[3]).to eql(t_one)
          expect(serialized[2]).to eql(t_two)
          expect(serialized[1]).to eql(t_three)
          expect(serialized[0]).to eql(t_four)
        end
      end
    end
  end
end
