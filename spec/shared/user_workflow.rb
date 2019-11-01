# frozen_string_literal: true

RSpec.shared_context 'user workflow' do
  let(:user_workflow_class) do
    workflow_class = Class.new do
      include Attr::Gather::Workflow

      task :good do |t|
        t.depends_on = []
      end

      task :bad do |t|
        t.depends_on = []
      end
    end

    workflow_class.container(user_container)
    workflow_class.filter(:contract, user_contract.new)
    workflow_class
  end

  let(:user_contract) do
    require 'dry-validation'

    Class.new(Dry::Validation::Contract) do
      params do
        optional(:email).filled(:str?, format?: /@/)
      end
    end
  end
end
