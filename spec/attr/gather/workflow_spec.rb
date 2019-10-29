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
            t.depends_on = []
          end

          task :fetch_from_pim do |t|
            t.depends_on = []
          end

          task :tag_from_images do |t|
            t.depends_on = %i[fetch_from_xml_catalog fetch_from_pim]
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

        first_batch_results = {
          foo: :bar,
          fetch_from_pim_ran: be_a(Hash),
          fetch_from_xml_catalog_ran: { foo: :bar }
        }

        expect(result.value!).to include(
          **first_batch_results,
          tag_from_images_ran: {
            **first_batch_results
          }
        )
      end

      describe '.aggregator' do
        it 'has a configurable aggregator' do
          simple_workflow_class.aggregator(:shallow_merge)
          simple_workflow_class.container(simple_container)

          workflow = simple_workflow_class.new
          result = workflow.call({})

          expect(result.value!).to eql(id: :second)
        end

        it 'has configurable options' do
          simple_workflow_class.aggregator(:shallow_merge, reverse: true)
          simple_workflow_class.container(simple_container)

          workflow = simple_workflow_class.new
          result = workflow.call({})

          expect(result.value!).to eql(id: :first)
        end
      end
    end
  end
end
