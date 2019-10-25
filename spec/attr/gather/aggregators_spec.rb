# frozen_string_literal: true

module Attr
  module Gather
    RSpec.describe Aggregators do
      describe '.default' do
        it 'is the :deep_merge aggregator' do
          expect(described_class.default).to be_a(Aggregators::DeepMerge)
        end
      end

      describe '.resolve' do
        it 'resolves a named aggregator' do
          result = described_class.resolve(:deep_merge)

          expect(result).to be_a(Aggregators::DeepMerge)
        end

        it 'raises a meaningful error when no aggregator is found' do
          expect do
            described_class.resolve(:invalid)
          end.to raise_error(Aggregators::Registry::NoAggregatorFoundError)
        end
      end
    end
  end
end
