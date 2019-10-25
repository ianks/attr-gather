# frozen_string_literal: true

require 'attr/gather/aggregators/deep_merge'

module Attr
  module Gather
    module Aggregators
      RSpec.describe DeepMerge do
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

              expect(res).to eql(user: { name: 'ian', id: 1, email: 't@t.com' })
            end

            it 'prioritizes results from later tasks' do
              res = aggregator.call(
                { user: { name: 'ian' } },
                [
                  val(user: { id: 1 }),
                  val(user: { id: 2 })
                ]
              )

              expect(res).to eql(user: { name: 'ian', id: 2 })
            end
          end

          def val(hash)
            double(value!: hash)
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

              expect(res).to eql(user: { name: 'ian', id: 1 })
            end
          end

          def val(hash)
            double(value!: hash)
          end
        end
      end
    end
  end
end
