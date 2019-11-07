# frozen_string_literal: true

require 'attr/gather/filters/noop'

module Attr
  module Gather
    module Filters
      RSpec.describe Noop do
        subject(:noop_filter) { described_class.new }

        describe '#call' do
          it 'does not remove any keys' do
            res = noop_filter.call(test: true)

            expect(res).to have_attributes(value: { test: true })
          end

          it 'returns a result with no filterings' do
            res = noop_filter.call(test: true)

            expect(res).to have_attributes(filterings: [])
          end
        end
      end
    end
  end
end
