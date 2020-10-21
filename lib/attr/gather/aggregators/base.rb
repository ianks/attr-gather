# frozen_string_literal: true

require 'attr/gather/filters/noop'

module Attr
  module Gather
    module Aggregators
      # @abstract Subclass and override {#call} to implement
      #   a custom Aggregator class.
      #
      # @!attribute [r] filter
      #   @return [Attr::Gather::Filters::Base] filter for the output data
      class Base
        attr_accessor :filter

        NOOP_FILTER ||= Filters::Noop.new

        def initialize(**opts)
          @filter = opts.delete(:filter) || NOOP_FILTER
        end

        def call(_original_input, _results_array)
          raise NotImplementedError
        end

        private

        def wrap_result(result)
          Concurrent::Promise.fulfill(result)
        end

        def unwrap_result(res)
          unvalidated = res.result.value!

          return unvalidated if filter.nil?

          filter.call(unvalidated).value
        end
      end
    end
  end
end
