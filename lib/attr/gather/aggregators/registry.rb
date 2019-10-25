# frozen_string_literal: true

module Attr
  module Gather
    module Aggregators
      # Registry for known result aggregators
      #
      # @api private
      class Registry
        # @api private
        Storage = Hash[]

        # Error raised when aggregator name already exists
        class AggregatorAlreadyRegisteredError < Error; end

        # Error raised when no aggregator is found
        class NoAggregatorFoundError < Attr::Gather::Error; end

        class << self
          def register(name, &blk)
            name = name.to_sym

            Storage[name] = blk
          end

          def resolve(name, options)
            block = Storage.fetch(name) do
              raise NoAggregatorFoundError,
                    "no aggregator with name #{name} registered"
            end

            block.call(options)
          end

          def ensure_name_not_already_registered!(name)
            return unless Storage.key?(name)

            raise AggregatorAlreadyRegisteredError,
                  "aggregator with name #{name} already registered"
          end
        end
      end
    end
  end
end
