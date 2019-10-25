# frozen_string_literal: true

module Attr
  module Gather
    RSpec.describe Aggregators do
      describe '.default' do
        it 'is the :ordered_deep_merge aggregator' do
          expect(described_class.default).to be_a(Aggregators::OrderedDeepMerge)
        end
      end

      describe '.resolve' do
        it 'resolves a named aggregator' do
          result = described_class.resolve(:ordered_deep_merge)

          expect(result).to be_a(Aggregators::OrderedDeepMerge)
        end

        it 'raises a meaningful error when no aggregator is found' do
          expect do
            described_class.resolve(:invalid)
          end.to raise_error(Aggregators::NoAggregatorFoundError)
        end
      end
    end
  end
end
