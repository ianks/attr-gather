# frozen_string_literal: true

require 'attr/gather/aggregators/base'

module Attr
  module Gather
    module Aggregators
      # Shallowly merges results
      #
      # @api public
      class ShallowMerge < Base
        # Initialize a new DeepMerge aggregator
        #
        # @param reverse [Boolean] merge results in reverse order
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
          initial = merge_input? ? input.dup : {}

          result = execution_results.reduce(initial) do |memo, res|
            memo.merge(unwrap_result(res))
          end

          wrap_result(result)
        end

        private

        def reverse?
          @reverse
        end

        def merge_input?
          @merge_input
        end
      end
    end
  end
end
