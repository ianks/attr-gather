# frozen_string_literal: true

require 'attr/gather/aggregators/registry'

module Attr
  module Gather
    # Namespace for aggregators
    module Aggregators
      # Error raised when no aggregator is found
      class NoAggregatorFoundError < Attr::Gather::Error; end

      # Register a named aggregator
      #
      # Registered aggregators can be accessed by name
      #
      # @param name [Symbol] name of the aggregator
      # @yield [options] block to initialize the aggregator
      def self.register_aggregator(name, &blk)
        Registry.register(name, &blk)
      end

      # Resolve a named aggregator
      #
      # @param name [Symbol]
      #
      # @return [#call]
      def self.resolve(name)
        Registry.resolve(name)
      rescue Dry::Container::Error => e
        raise NoAggregatorFoundError, e.message
      end

      # The default aggregator if none is specified
      #
      # @return [Attr::Gather::Aggregators::OrderedDeepMerge]
      def self.default
        @default = Registry.resolve(:ordered_deep_merge)
      end

      register_aggregator(:ordered_deep_merge) do
        require 'attr/gather/aggregators/ordered_deep_merge'

        OrderedDeepMerge.new
      end

      register_aggregator(:shallow_merge) do
        require 'attr/gather/aggregators/shallow_merge'

        ShallowMerge.new
      end
    end
  end
end
