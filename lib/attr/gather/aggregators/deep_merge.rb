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
        # @param merge_input [Boolean] include input in aggregation result
        #
        # @api private
        def initialize(reverse: false, merge_input: true, **)
          @reverse = reverse
          @merge_input = merge_input
          super
        end

        def call(input, execution_results)
          execution_results = execution_results.reverse_each if reverse?
          initial = unwrap_initial_input(input)

          result = execution_results.reduce(initial) do |memo, res|
            deep_merge(memo, unwrap_result(res))
          end
        end

        private

        def unwrap_initial_input(input)
          merge_input? ? filter.call(input.dup).value : {}
        end

        def reverse?
          @reverse
        end

        def merge_input?
          @merge_input
        end

        def deep_merge(hash, other)
          Hash[hash].merge(other) do |_, orig, new|
            if orig.respond_to?(:to_hash) && new.respond_to?(:to_hash)
              deep_merge(Hash[orig], Hash[new])
            else
              new
            end
          end
        end
      end
    end
  end
end
