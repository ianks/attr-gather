# frozen_string_literal: true

RSpec.shared_context 'task execution result' do
  def task_exeution_result(hash)
    instance_double(Workflow::TaskExecutionResult, result: double(value!: hash))
  end
end
