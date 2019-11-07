# frozen_string_literal: true

module Attr
  module Gather
    RSpec.describe Filters do
      describe '.default' do
        it 'is the :noop filter' do
          expect(described_class.default).to be_a(Filters::Noop)
        end
      end

      describe '.resolve' do
        include_context 'user workflow'

        it 'resolves a named aggregator' do
          res = described_class.resolve(:contract, user_contract.new)

          expect(res).to be_a(Filters::Contract)
        end

        it 'raises a meaningful error when no aggregator is found' do
          expect do
            described_class.resolve(:invalid)
          end.to raise_error(Registrable::NotFoundError)
        end
      end
    end
  end
end
