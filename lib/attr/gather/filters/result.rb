# frozen_string_literal: true

module Attr
  module Gather
    module Filters
      # Result of a filter
      #
      # @!attribute [r] value
      #   @return [Hash] the filtered hash
      #
      # @!attribute [r] filterings
      #   @return [Array<Attr::Gather::Filtering>] info about filtered items
      class Result
        attr_reader :value, :filterings

        def initialize(value, filterings)
          @value = value
          @filterings = filterings
        end
      end
    end
  end
end
