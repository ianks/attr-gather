# frozen_string_literal: true

RSpec.shared_context 'test container' do
  let(:test_container) do
    container = Dry::Container.new

    container.register(:fetch_from_xml_catalog) do |input|
      { fetch_from_xml_catalog_ran: input }
    end

    container.register(:fetch_from_pim) do |input|
      { fetch_from_pim_ran: input }
    end

    container.register(:tag_from_images) do |input|
      { tag_from_images_ran: input }
    end
  end

  let(:simple_container) do
    container = Dry::Container.new

    container.register(:first) do |_input|
      { id: :first }
    end

    container.register(:second) do |_input|
      { id: :second }
    end
  end

  let(:simple_workflow_class) do
    workflow_class = Class.new do
      include Attr::Gather::Workflow

      task :first do |t|
        t.depends_on = []
      end

      task :second do |t|
        t.depends_on = []
      end
    end

    workflow_class.container(simple_container)

    workflow_class
  end
end
