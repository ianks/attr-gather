# frozen_string_literal: true

require 'attr/gather/concerns/registrable'

module Attr
  module Gather
    # Namespace for aggregators
    module Aggregators
      extend Registrable

      # The default aggregator if none is specified
      #
      # @return [Attr::Gather::Aggregators::DeepMerge]
      def self.default
        @default = resolve(:deep_merge)
      end

      register(:deep_merge) do |*args|
        require 'attr/gather/aggregators/deep_merge'

        DeepMerge.new(*args)
      end

      register(:shallow_merge) do |*args|
        require 'attr/gather/aggregators/shallow_merge'

        ShallowMerge.new(*args)
      end
    end
  end
end
