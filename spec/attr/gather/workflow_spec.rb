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

      it 'has a chainable result' do
        result = workflow.call(foo: :bar).then { |res| res.merge(chain: true) }

        expect(result.value!).to include(chain: true)
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

      describe '#uuid' do
        it 'has a uuid attribute' do
          expect(workflow_class.new).to have_attributes(uuid: be_a_uuid)
        end
      end

      describe '.filter' do
        include_context 'user workflow'

        let(:user_container) do
          container = Dry::Container.new

          container.register(:good) do |_input|
            { email: 'test@test.com' }
          end

          container.register(:bad) do |_input|
            { email: 'notanemail' }
          end
        end

        it 'filters out bad values' do
          workflow = user_workflow_class.new
          result = workflow.call({})

          expect(result.value!).to eql(email: 'test@test.com')
        end
      end

      describe '.filter_with_contract' do
        include_context 'user workflow'

        let(:user_container) do
          container = Dry::Container.new

          container.register(:good) do |_input|
            { email: 'test@test.com' }
          end

          container.register(:bad) do |_input|
            { email: 'notanemail' }
          end
        end

        it 'creates a new contract filter with a block' do
          user_workflow_class.filter_with_contract do
            params do
              optional(:foo).filled(:str?)
            end
          end

          workflow = user_workflow_class.new
          result = workflow.call(foo: 'bar')

          expect(result.value!).to eql(foo: 'bar')
        end

        it 'allows for contract as an arg' do
          contract_class = Class.new(Dry::Validation::Contract) do
            params do
              optional(:foo).filled(:str?)
            end
          end

          user_workflow_class.filter_with_contract(contract_class.new)

          workflow = user_workflow_class.new
          result = workflow.call(foo: 'bar')

          expect(result.value!).to eql(foo: 'bar')
        end

        context 'when a task fails' do
          let(:user_container) do
            container = Dry::Container.new

            container.register(:good) do |_input|
              { email: 'test@test.com' }
            end

            container.register(:bad) do |_input|
              raise 'oh no!'
            end
          end

          it 'bubbles the exception' do
            workflow = user_workflow_class.new
            result = workflow.call({})

            expect do
              result.value!
            end.to raise_error(RuntimeError, 'oh no!')
          end
        end
      end
    end
  end
end
