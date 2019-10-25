# frozen_string_literal: true

require 'attr/gather/aggregators/base'

module Attr
  module Gather
    module Aggregators
      # Shallowly merges results in order from first to last
      #
      # @api public
      class ShallowMerge < Base
        def call(input, results_array)
          results_array.reduce(input.dup) do |memo, res|
            memo.merge(res.value!)
          end
        end
      end
    end
  end
end
