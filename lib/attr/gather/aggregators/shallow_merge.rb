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
        #
        # @api private
        def initialize(reverse: false, **)
          @reverse = reverse
          super
        end

        def call(input, execution_results)
          execution_results = execution_results.reverse_each if reverse?

          execution_results.reduce(input) do |memo, res|
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
