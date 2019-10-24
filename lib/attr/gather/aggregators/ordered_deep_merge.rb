# frozen_string_literal: true

module Attr
  module Gather
    module Aggregators
      # Deeply merges results in order from first to last
      #
      # @api public
      class OrderedDeepMerge
        def call(input, results_array)
          results_array.reduce(input.dup) do |memo, res|
            deep_merge(memo, res.value!)
          end
        end

        private

        def deep_merge(hash, other)
          Hash[hash].merge(other) do |_, orig_val, new_val|
            if orig_val.respond_to?(:to_hash) && new_val.respond_to?(:to_hash)
              deep_merge(Hash[orig_val], Hash[new_val])
            else
              new_val
            end
          end
        end
      end
    end
  end
end
