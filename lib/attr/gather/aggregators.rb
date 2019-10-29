# frozen_string_literal: true

require 'attr/gather/aggregators/registry'

module Attr
  module Gather
    # Namespace for aggregators
    module Aggregators
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
      def self.resolve(name, opts = Attr::Gather::EMPTY_HASH)
        Registry.resolve(name, opts)
      end

      # The default aggregator if none is specified
      #
      # @return [Attr::Gather::Aggregators::DeepMerge]
      def self.default
        @default = resolve(:deep_merge)
      end

      register_aggregator(:deep_merge) do |opts|
        require 'attr/gather/aggregators/deep_merge'

        DeepMerge.new(opts)
      end

      register_aggregator(:shallow_merge) do |opts|
        require 'attr/gather/aggregators/shallow_merge'

        ShallowMerge.new(opts)
      end
    end
  end
end
