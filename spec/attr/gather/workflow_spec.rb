# frozen_string_literal: true

require 'dry-container'

module Attr
  module Gather
    RSpec.describe Workflow do
      include_context 'test container'

      let(:workflow_class) do
        workflow_class = Class.new do
          include Attr::Gather::Workflow

          task :fetch_from_xml_catalog do |t|
            t.provider = :xml_catalog
            t.depends_on = []
          end

          task :fetch_from_pim do |t|
            t.provider = :pim_catalog
            t.depends_on = []
          end

          task :tag_from_images do |t|
            t.provider = :image_tagger
            t.depends_on = %i[pim_catalog xml_catalog]
          end
        end

        workflow_class.container(test_container)

        workflow_class
      end

      subject(:workflow) do
        workflow_class.new
      end

      it 'includes the initial input in the result' do
        result = workflow.call(foo: :bar)

        expect(result.value!).to include(foo: :bar)
      end

      it 'returns the attrs from all of the tasks in the result' do
        result = workflow.call(foo: :bar)

        expect(result.value!.keys).to include(
          :fetch_from_xml_catalog_ran,
          :fetch_from_pim_ran,
          :tag_from_images_ran
        )
      end

      it 'runs the workflow in order' do
        result = workflow.call(foo: :bar)

        expect(result.value!).to include(
          fetch_from_xml_catalog_ran: have_key(:foo),
          fetch_from_pim_ran: have_key(:fetch_from_xml_catalog_ran),
          tag_from_images_ran: have_key(:fetch_from_pim_ran)
        )
      end
    end
  end
end
