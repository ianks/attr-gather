# frozen_string_literal: true

module Attr
  module Gather
    module Filters
      # Information about a filtered item
      #
      # @!attribute [r] path
      #   @return [Hash] path of the filtered key
      #
      # @!attribute [r] reason
      #   @return [String] why the item was filtered
      #
      # @!attribute [r] input
      #   @return [String] input value that was filtered
      class Filtering
        attr_reader :path, :reason, :input

        def initialize(path, reason, input)
          @path = path
          @reason = reason
          @input = input
        end
      end
    end
  end
end
