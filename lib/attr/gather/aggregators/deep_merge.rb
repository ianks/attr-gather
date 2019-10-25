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
        #
        # @api private
        def initialize(reverse: false)
          @reverse = reverse
        end

        def call(input, results_array)
          results_array = results_array.reverse_each if reverse?

          results_array.reduce(input.dup) do |memo, res|
            deep_merge(memo, res.value!)
          end
        end

        private

        def reverse?
          @reverse
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
