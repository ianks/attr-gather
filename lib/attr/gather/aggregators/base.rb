# frozen_string_literal: true

module Attr
  module Gather
    module Aggregators
      # @abstract Subclass and override {#call} to implement
      #   a custom Aggregator class.
      class Base
        def call(_original_input, _results_array)
          raise NotImplementedError
        end
      end
    end
  end
end
