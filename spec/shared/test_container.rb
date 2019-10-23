# frozen_string_literal: true

RSpec.shared_context 'test container' do
  let(:test_container) do
    container = Dry::Container.new

    container.register(:fetch_from_xml_catalog) do |input|
      { **input, fetch_from_xml_catalog_ran: input }
    end

    container.register(:fetch_from_pim) do |input|
      { **input, fetch_from_pim_ran: input }
    end

    container.register(:tag_from_images) do |input|
      { **input, tag_from_images_ran: input }
    end
  end
end
