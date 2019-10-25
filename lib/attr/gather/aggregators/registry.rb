# frozen_string_literal: true

require 'dry-container'

module Attr
  module Gather
    module Aggregators
      # Registry for known result aggregators
      #
      # @api public
      class Registry
        extend Dry::Container::Mixin
      end
    end
  end
end
