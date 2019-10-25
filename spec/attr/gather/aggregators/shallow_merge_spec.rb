# frozen_string_literal: true

require 'attr/gather/aggregators/shallow_merge'

module Attr
  module Gather
    module Aggregators
      RSpec.describe ShallowMerge do
        describe '#call' do
          it 'shallow merges results' do
            res = subject.call(
              { user: { name: 'ian' } },
              [
                val(user: { id: 1 }),
                val(user: { email: 't@t.com' })
              ]
            )

            expect(res).to eql(user: { email: 't@t.com' })
          end

          it 'prioritizes based on order' do
            res = subject.call(
              { user: { name: 'ian' } },
              [
                val(user: { id: 1 }),
                val(user: { id: 2 })
              ]
            )

            expect(res).to eql(user: { id: 2 })
          end
        end

        def val(hash)
          double(value!: hash)
        end
      end
    end
  end
end
