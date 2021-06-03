# frozen_string_literal: true

require 'attr/gather/aggregators/base'

module Attr
  module Gather
    module Aggregators
      # Deep merges result hashes
      #
      # @api public
      class DeepMerge < Base
        # Initialize a new DeepMerge aggregator
        #
        # @param reverse [Boolean] deep merge results in reverse order
        # @param merge_input [Boolean] merge the result with the initial input
        # @param concat_arrays [Boolean] concat nested arrays
        #
        # @api private
        def initialize(reverse: false, merge_input: true, array_strategy: :concat, **)
          unless ARRAY_STRATEGY.include?(array_strategy)
            raise ArgumentError, 'array_strategy must be one of: :concat, :overwrite'
          end

          @reverse = reverse
          @merge_input = merge_input
          @array_strategy = array_strategy

          super
        end

        def call(input, execution_results)
          execution_results = execution_results.reverse_each if reverse?

          execution_results.reduce(@merge_input ? input : EMPTY_HASH) do |memo, res|
            deep_merge(memo, unwrap_result(res))
          end
        end

        private

        ARRAY_STRATEGY = %i[concat overwrite].freeze

        private_constant :ARRAY_STRATEGY

        def deep_merge(hash, other)
          Hash[hash].merge(other) do |_, orig, new|
            if orig.respond_to?(:to_hash) && new.respond_to?(:to_hash)
              deep_merge(Hash[orig], Hash[new])
            elsif concattable?(orig, new)
              orig + new
            else
              new
            end
          end
        end

        def concattable?(orig, new)
          return false unless @array_strategy == :concat

          concattable_class?(orig) && concattable_class?(new)
        end

        def concattable_class?(obj)
          return true if obj.is_a?(Array)
          return true if obj.is_a?(Set)

          false
        end

        def reverse?
          @reverse
        end
      end
    end
  end
end
