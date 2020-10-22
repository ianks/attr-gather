# frozen_string_literal: true

require 'attr/gather/workflow/task'
require 'attr/gather/workflow/task_graph'

module Attr
  module Gather
    module Workflow
      RSpec.describe TaskGraph do
        describe '#<<' do
          it 'raises when a depends_on task does not exist' do
            graph = described_class.new

            expect do
              graph << Hash[name: :foo, depends_on: [:does_not_exist]]
            end.to raise_error(TaskGraph::InvalidTaskDepedencyError)
          end
        end

        describe '#to_a' do
          it 'sorts tasks topologically' do
            t_one = Hash[name: :one, depends_on: []]
            t_two = Hash[name: :two, depends_on: [:one]]
            t_three = Hash[name: :three, depends_on: [:two]]
            t_four = Hash[name: :four, depends_on: [:three]]

            graph = described_class.new(tasks: [t_one, t_two, t_three, t_four])
            serialized = graph.to_a

            expect(serialized[0]).to match_task(t_one)
            expect(serialized[1]).to match_task(t_two)
            expect(serialized[2]).to match_task(t_three)
            expect(serialized[3]).to match_task(t_four)
          end
        end

        describe '#each_strongly_connected_component' do
          it 'batches tasks topologically' do
            t_one = Hash[name: :one, depends_on: []]
            t_two = Hash[name: :two, depends_on: [:one]]
            t_three = Hash[name: :three, depends_on: [:two]]
            t_four = Hash[name: :four, depends_on: [:two]]

            graph = described_class.new(tasks: [t_one, t_two, t_three, t_four])
            serialized = graph.to_a

            expect(serialized[0]).to match_task(t_one)
            expect(serialized[1]).to match_task(t_two)
            expect(serialized[2]).to match_task(t_three)
            expect(serialized[3]).to match_task(t_four)
          end
        end

        describe '#to_h' do
          it 'builds a hash of the deps' do
            t_one = Hash[name: :one, depends_on: []]
            t_two = Hash[name: :two, depends_on: [:one]]
            t_three = Hash[name: :three, depends_on: [:two]]
            t_four = Hash[name: :four, depends_on: [:two]]

            graph = described_class.new(tasks: [t_one, t_two, t_three, t_four])

            find = ->(hash) { graph.to_a.find { |t| t.name == hash[:name] } }

            expect(graph.to_h).to eql(
              find.call(t_one) => [],
              find.call(t_two) => [find.call(t_one)],
              find.call(t_three) => [find.call(t_two)],
              find.call(t_four) => [find.call(t_two)]
            )
          end
        end

        describe '#to_dot' do
          it 'builds a dot string' do
            t_one = Hash[name: :one, depends_on: []]
            t_two = Hash[name: :two, depends_on: [:one]]
            t_three = Hash[name: :three, depends_on: [:one]]
            t_four = Hash[name: :four, depends_on: %i[two three]]

            graph = described_class.new(tasks: [t_one, t_two, t_three, t_four])

            expect(graph.to_dot).to eql <<~DOT
              digraph TaskGraph {
                one -> two;
                one -> three;
                two -> four;
                three -> four;
              }
            DOT
          end
        end

        describe '#each_batch' do
          it 'yields batches of concurrently executable tasks' do
            t_one = Hash[name: :one, depends_on: []]
            t_two = Hash[name: :two, depends_on: [:one]]
            t_three = Hash[name: :three, depends_on: [:two]]
            t_four = Hash[name: :four, depends_on: [:two]]

            graph = described_class.new(tasks: [t_one, t_two, t_three, t_four])
            batches = graph.each_batch.to_a

            expect(batches).to contain_exactly(
              contain_exactly(match_task(t_one)),
              contain_exactly(match_task(t_two)),
              contain_exactly(match_task(t_three), match_task(t_four))
            )
          end
        end

        describe '#runnable_tasks' do
          it 'yields batches of concurrently executable tasks' do
            t_one = Hash[name: :one, depends_on: []]
            t_two = Hash[name: :two, depends_on: []]
            t_three = Hash[name: :three, depends_on: [:two]]
            graph = described_class.new(tasks: [t_one, t_two, t_three])

            expect(graph.runnable_tasks).to contain_exactly(
              match_task(t_one),
              match_task(t_two)
            )
          end
        end

        def t(**opts)
          Task.new(**opts)
        end

        def match_task(opts)
          have_attributes(name: opts[:name])
        end
      end
    end
  end
end
