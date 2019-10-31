# frozen_string_literal: true

require 'securerandom'

module Attr
  module Gather
    module Concerns
      # Makes an entity identifiable by adding a #uuid attribute
      #
      # @!attribute [r] uuid
      #   @return [String] UUID of the result
      module Identifiable
        def initialize(*)
          @uuid = SecureRandom.uuid
          super
        end

        def self.included(klass)
          klass.attr_reader(:uuid)
        end
      end
    end
  end
end
