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
        # @param merge_input [Boolean] merge the result with the initial input
        #
        # @api private
        def initialize(reverse: false, merge_input: true, **)
          @reverse = reverse
          @merge_input = merge_input
          super
        end

        def call(input, execution_results)
          execution_results = execution_results.reverse_each if reverse?

          execution_results.reduce(@merge_input ? input : EMPTY_HASH) do |memo, res|
            memo.merge(unwrap_result(res))
          end
        end

        private

        def reverse?
          @reverse
        end
      end
    end
  end
end
