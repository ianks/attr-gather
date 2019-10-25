# frozen_string_literal: true

require 'attr/gather/aggregators/shallow_merge'

module Attr
  module Gather
    module Aggregators
      RSpec.describe ShallowMerge do
        context 'when used with default options' do
          subject(:aggregator) { described_class.new }

          describe '#call' do
            it 'deeply merges results' do
              res = aggregator.call(
                { user: { name: 'ian' } },
                [
                  val(user: { id: 1 }),
                  val(user: { email: 't@t.com' })
                ]
              ).value!

              expect(res).to eql(user: { email: 't@t.com' })
            end

            it 'prioritizes results from later tasks' do
              res = aggregator.call(
                { user: { name: 'ian' } },
                [
                  val(user: { id: 1 }),
                  val(user: { id: 2 })
                ]
              ).value!

              expect(res).to eql(user: { id: 2 })
            end
          end
        end

        context 'when used with reverse: true' do
          subject(:aggregator) { described_class.new(reverse: true) }

          describe '#call' do
            it 'prioritizes results from earlier tasks' do
              res = aggregator.call(
                { user: { name: 'ian' } },
                [
                  val(user: { id: 1 }),
                  val(user: { id: 2 })
                ]
              ).value!

              expect(res).to eql(user: { id: 1 })
            end
          end
        end

        def val(hash)
          instance_double(Workflow::TaskExecutionResult, result: double(value!: hash))
        end
      end
    end
  end
end
