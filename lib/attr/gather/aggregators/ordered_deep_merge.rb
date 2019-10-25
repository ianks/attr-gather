# frozen_string_literal: true

require 'attr/gather/aggregators/base'

module Attr
  module Gather
    module Aggregators
      # Deeply merges results in order from first to last
      #
      # @api public
      class OrderedDeepMerge < Base
        def call(input, results_array)
          results_array.reduce(input.dup) do |memo, res|
            deep_merge(memo, res.value!)
          end
        end

        private

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
