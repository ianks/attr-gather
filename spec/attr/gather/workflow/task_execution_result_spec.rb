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

        describe '#ran_at' do
          it 'returns a time' do
            result = double(value!: { foo: :bar })
            task = instance_double(Task)
            task_execution_result = described_class.new(task, result)

            expect(task_execution_result.ran_at).to respond_to(:year)
          end
        end
      end
    end
  end
end
