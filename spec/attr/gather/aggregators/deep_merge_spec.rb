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

            it 'merges arrays by default' do
              res = aggregator.call(
                { user: {} },
                [
                  val(user: { tags: [:foo] }),
                  val(user: { tags: [:bar] })
                ]
              )

              expect(res).to eql(user: { tags: %i[foo bar] })
            end

            it 'merges sets' do
              res = aggregator.call(
                { user: {} },
                [
                  val(user: { tags: [:foo].to_set }),
                  val(user: { tags: [:foo].to_set })
                ]
              )

              expect(res).to eql(user: { tags: [:foo].to_set })
            end
          end
        end

        context 'when used with array_strategy: :overwrite' do
          subject(:aggregator) { described_class.new(array_strategy: :overwrite) }

          describe '#call' do
            it 'does not concat arrays' do
              res = aggregator.call(
                { user: {} },
                [
                  val(user: { tags: [:foo] }),
                  val(user: { tags: [:bar] })
                ]
              )

              expect(res).to eql(user: { tags: [:bar] })
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

              expect(res).to eql(user: { name: 'ian', id: 1 })
            end
          end
        end

        context 'when used with merge_input: false' do
          subject(:aggregator) { described_class.new(merge_input: false) }

          describe '#call' do
            it 'prioritizes results from earlier tasks' do
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
