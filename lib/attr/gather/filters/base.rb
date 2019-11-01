# frozen_string_literal: true

module Attr
  module Gather
    module Filters
      # @abstract Subclass and override {#call} to implement
      #   a custom Filter class.
      class Base
        # Applies the filter
        #
        # @param _input [Hash]
        #
        # @return [Attr::Gather::Filter::Result]
        def call(_input)
          raise NotImplementedError
        end
      end
    end
  end
end
