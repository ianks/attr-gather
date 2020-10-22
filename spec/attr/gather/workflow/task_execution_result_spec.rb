# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # @api private
      RSpec.describe TaskExecutionResult do
        describe '#value!' do
          it 'returns the underlying result value' do
            result = double(value!: { foo: :bar })
            task = instance_double(Task)
            task_execution_result = described_class.new(task, result)

            expect(task_execution_result.value!).to eql(foo: :bar)
          end
        end

        describe '#started_at' do
          it 'returns a time' do
            result = double(value!: { foo: :bar })
            task = instance_double(Task)
            task_execution_result = described_class.new(task, result)

            expect(task_execution_result.started_at).to respond_to(:year)
          end
        end

        describe '#uuid' do
          it 'returns a uuid' do
            result = double(value!: { foo: :bar })
            task = instance_double(Task)
            task_execution_result = described_class.new(task, result)

            expect(task_execution_result.uuid).to be_a_uuid
          end
        end

        describe '#state' do
          it 'uses the result promise state' do
            result = double(state: :pending)
            task = instance_double(Task)
            task_execution_result = described_class.new(task, result)

            expect(task_execution_result).to have_attributes(
              state: result.state
            )
          end
        end

        describe '#then' do
          it 'delegates to the result' do
            result = Concurrent::Promise.execute { :foo }
            task = instance_double(Task)
            orig_result = described_class.new(task, result)
            new_result = orig_result.then { :bar }

            expect(orig_result.value!).to eql(:foo)
            expect(new_result.value!).to eql(:bar)
          end
        end

        describe '#catch' do
          it 'delegates to the result' do
            result = Concurrent::Promise.execute { raise 'oh no!' }
            task = instance_double(Task)
            orig_result = described_class.new(task, result)
            new_result = orig_result.catch(&:message)

            expect { orig_result.value! }.to raise_error(RuntimeError, 'oh no!')
            expect(new_result.value!).to eql('oh no!')
          end
        end

        describe '#as_json' do
          it 'is serializable as a hash' do
            task = Task.new(name: :foobar, depends_on: [])
            result = Concurrent::Promise.fulfill(Hash[foo: :bar])
            task_execution_result = described_class.new(task, result)

            expect(task_execution_result.as_json).to include(
              started_at: respond_to(:year),
              task: { name: :foobar, depends_on: [] },
              state: :fulfilled,
              value: { foo: :bar }
            )
          end
        end
      end
    end
  end
end
