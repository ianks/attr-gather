# frozen_string_literal: true

module Attr
  module Gather
    # Makes a module registrable
    module Registrable
      # Error raised when item is already registered
      class AlreadyRegisteredError < Error; end

      # Error raised when item is not found
      class NotFoundError < Attr::Gather::Error; end

      def self.extended(klass)
        klass.instance_variable_set(:@__storage__, {})
      end

      # Register item so it can be accessed by name
      #
      # @param name [Symbol] name of the item
      # @yield [options] block to initialize the item
      def register(name, &blk)
        name = name.to_sym

        @__storage__[name] = blk
      end

      # Resolve a named item
      #
      # @param name [Symbol]
      #
      # @return [#call]
      def resolve(name, *args, **opts)
        block = @__storage__.fetch(name) do
          raise NotFoundError,
                "no item with name #{name} registered"
        end

        block.call(*args, **opts)
      end

      # @api private
      def ensure_name_not_already_registered!(name)
        return unless @__storage__.key?(name)

        raise AlreadyRegisteredError,
              "item with name #{name} already registered"
      end
    end
  end
end
