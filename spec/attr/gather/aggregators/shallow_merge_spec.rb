# frozen_string_literal: true

require 'attr/gather/aggregators/shallow_merge'

module Attr
  module Gather
    module Aggregators
      RSpec.describe ShallowMerge do
        include_context 'task execution result'

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
              )

              expect(res).to eql(user: { email: 't@t.com' })
            end

            it 'prioritizes results from later tasks' do
              res = aggregator.call(
                { user: { name: 'ian' } },
                [
                  val(user: { id: 1 }),
                  val(user: { id: 2 })
                ]
              )

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
              )

              expect(res).to eql(user: { id: 1 })
            end
          end
        end

        context 'when used with merge_input: false' do
          subject(:aggregator) { described_class.new(merge_input: false) }

          describe '#call' do
            it 'does not inclue the input in the merged result' do
              res = aggregator.call(
                { user: { name: 'ian' } },
                [
                  val(user: { id: 1 })
                ]
              )

              expect(res).to eql(user: { id: 1 })
            end
          end
        end

        def val(hash)
          hash
        end
      end
    end
  end
end
