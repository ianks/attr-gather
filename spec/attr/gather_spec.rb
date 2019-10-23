# frozen_string_literal: true

module Attr
  RSpec.describe Gather do
    it 'has a version number' do
      expect(Attr::Gather::VERSION).not_to be nil
    end
  end
end
