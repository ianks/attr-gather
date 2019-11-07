# frozen_string_literal: true

module Attr
  module Gather
    module Filters
      # Filters values with a dry-validation contract
      class Contract < Base
        class IncompatibleContractError < Error; end

        attr_reader :dry_contract

        # Creates a new instance of the filter
        #
        # @param dry_contract [Dry::Contract]
        def initialize(dry_contract)
          validate_dry_contract!(dry_contract)

          @dry_contract = dry_contract
        end

        def call(input)
          value, filterings = filter_validation_errors input.dup

          Result.new(value, filterings)
        end

        private

        def filter_validation_errors(unvalidated)
          contract_result = dry_contract.call(unvalidated)
          errors = contract_result.errors
          contract_hash = contract_result.to_h
          errors.each { |err| filter_error_from_input(err, contract_hash) }
          filterings = transform_errors_to_filtered_attributes(errors)

          [contract_hash, filterings]
        end

        def filter_error_from_input(error, input)
          *path, key_to_delete = error.path
          target = path.empty? ? input : input.dig(*path)
          target.delete(key_to_delete)
        end

        def transform_errors_to_filtered_attributes(errors)
          errors.map do |err|
            Filtering.new(err.path, err.text, err.input)
          end
        end

        def validate_dry_contract!(con)
          return if con.respond_to?(:call) && con.class.respond_to?(:schema)

          raise IncompatibleContractError, 'contract is not compatible'
        end
      end
    end
  end
end
