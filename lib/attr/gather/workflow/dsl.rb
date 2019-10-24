# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # DSL for configuring a workflow
      #
      # @api public
      module DSL
        # Defines a task with name and options
        #
        # @param task_name [Symbol] the name of the task
        #
        # @example
        #   class EnhanceUserProfile
        #     extend Attr::Gather::Workflow
        #
        #     # ...
        #
        #     task :fetch_database_info do |t|
        #       t.provider = :users_database
        #       t.depends_on = []
        #     end
        #
        #     task :fetch_avatar_info do |t|
        #       t.provider   = :gravatar_api
        #       t.depends_on = [:fetch_gravatar_info]
        #     end
        #   end
        #
        # Calling `task` will yield a task object which you can configure like
        # a PORO. Tasks will be registered for execution in the workflow.
        #
        # @yield [Attr::Gather::Workflow::Task] A task to configure
        #
        # @api public
        def task(task_name)
          task = Task.new(name: task_name)
          yield task
          tasks << task
        end

        # Defines a container for task dependencies
        #
        # Using a container  makes it easy to re-use workflows with different
        # data sources. Say one workflow was required to use a legacy DB, and
        # one wanted to use a new DB. Using a container makes it easy to
        # configure that dependency.
        #
        # @example
        #   LegacySystem = Dry::Container.new.tap do |c|
        #     c.register(:database) { Sequel.connect('sqlite://legacy.db')
        #   end
        #
        #   class EnhanceUserProfile
        #     extend Attr::Gather::Workflow
        #
        #     container LegacySystem
        #   end
        #
        # @param cont [Dry::Container] the Dry::Container to use
        #
        # @note For more information, check out {https://dry-rb.org/gems/dry-container}
        #
        # @api public
        def container(cont = nil)
          @container = cont if cont
          @container
        end
      end
    end
  end
end
