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

        def call(input, results_array)
          results_array = results_array.reverse_each if reverse?

          results_array.reduce(input.dup) do |memo, res|
            memo.merge(res.value!)
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
