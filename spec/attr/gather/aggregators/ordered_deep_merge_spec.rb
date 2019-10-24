# frozen_string_literal: true

module Attr
  module Gather
    module Aggregators
      RSpec.describe OrderedDeepMerge do
        describe '#call' do
          it 'deeply merges results' do
            res = subject.call(
              { user: { name: 'ian' } },
              [
                val(user: { id: 1 }),
                val(user: { email: 't@t.com' })
              ]
            )

            expect(res).to eql(user: { name: 'ian', id: 1, email: 't@t.com' })
          end

          it 'prioritizes based on order' do
            res = subject.call(
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
    end
  end
end
