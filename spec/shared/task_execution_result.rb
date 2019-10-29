# frozen_string_literal: true

RSpec.shared_context 'task execution result' do
  def task_exeution_result(hash)
    instance_double(
      Attr::Gather::Workflow::TaskExecutionResult,
      result: Concurrent::Promise.fulfill(hash)
    )
  end
end
