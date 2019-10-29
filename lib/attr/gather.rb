# frozen_string_literal: true

require 'attr/gather/version'

module Attr
  module Gather
    class Error < StandardError; end
    # Your code goes here...

    EMPTY_HASH = {}.freeze
  end
end

require 'attr/gather/workflow'
require 'attr/gather/aggregators'
