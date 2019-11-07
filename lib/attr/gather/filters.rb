# frozen_string_literal: true

require 'attr/gather/filters/base'
require 'attr/gather/filters/result'
require 'attr/gather/filters/filtering'
require 'attr/gather/concerns/registrable'

module Attr
  module Gather
    # Namespace for filters
    module Filters
      extend Registrable

      # The default filter if none is specified
      #
      # @return [Attr::Gather::Filters::Noop]
      def self.default
        @default = resolve(:noop)
      end

      register(:contract) do |contract|
        require 'attr/gather/filters/contract'

        Contract.new(contract)
      end

      register(:noop) do |*|
        require 'attr/gather/filters/noop'

        Noop.new
      end
    end
  end
end
