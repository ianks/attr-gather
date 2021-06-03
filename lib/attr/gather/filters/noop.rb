# frozen_string_literal: true

require 'attr/gather/filters/base'

module Attr
  module Gather
    module Filters
      # Does not perform any filtering
      class Noop < Base
        def call(input)
          Result.new(input, [])
        end
      end
    end
  end
end
