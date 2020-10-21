# frozen_string_literal: true

require 'attr/gather/filters/contract'

module Attr
  module Gather
    module Filters
      RSpec.describe Contract do
        subject(:contract_filter) { described_class.new(contract.new) }

        describe '#call' do
          let(:contract) do
            Class.new(Dry::Validation::Contract) do
              schema do
                optional(:email).filled(:str?, format?: /@/)
                optional(:country).hash do
                  required(:name).filled(:string)
                  required(:code).filled(:string)
                end
              end
            end
          end

          it 'removes keys with errors' do
            res = contract_filter.call(email: 'bad')

            expect(res).to have_attributes(value: {})
          end

          it 'removes specific nested keys with errors' do
            res = contract_filter.call(country: { name: 'test', code: nil })

            expect(res).to have_attributes(value: { country: { name: 'test' } })
          end

          it 'removes keys not specified in the contract' do
            res = contract_filter.call(
              country: { name: 'test', code: 't' },
              foo: 'bar'
            )

            expect(res).to have_attributes(
              value: { country: { name: 'test', code: 't' } }, filterings: []
            )
          end

          it 'returns a list of filter attributes' do
            res = contract_filter.call(country: { name: 'test', code: nil })

            filtered_code = have_attributes(
              path: %i[country code],
              reason: 'must be a string',
              input: nil
            )

            expect(res).to have_attributes(filterings: [filtered_code])
          end
        end

        describe '.new' do
          it 'raises when contract class in incompatible' do
            expect do
              described_class.new(proc {})
            end.to raise_error Contract::IncompatibleContractError
          end
        end
      end
    end
  end
end
