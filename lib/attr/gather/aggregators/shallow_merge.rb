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
        def initialize(reverse: false)
          @reverse = reverse
        end

        def call(input, execution_results)
          items = reverse? ? execution_results.reverse_each : execution_results

          result = items.reduce(input.dup) do |memo, res|
            memo.merge(res.result.value!)
          end

          wrap_result(result)
        end

        private

        def reverse?
          @reverse
        end
      end
    end
  end
end
