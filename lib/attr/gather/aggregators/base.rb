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

        private

        def wrap_result(result)
          Concurrent::Promise.fulfill(result)
        end
      end
    end
  end
end
