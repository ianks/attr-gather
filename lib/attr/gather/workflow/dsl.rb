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
        #       t.depends_on = []
        #     end
        #
        #     task :fetch_avatar_info do |t|
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
        def task(task_name, opts = EMPTY_HASH)
          task = Task.new(name: task_name, **opts)
          yield task
          tasks << task
          self
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

        # Configures the result aggregator
        #
        # Aggregators make is possible to build custom logic about
        # how results should be "merged" together. For example,
        # yuo could build and aggregator that prioritizes the
        # values of some tasks over others.
        #
        # @example
        #   class EnhanceUserProfile
        #     extend Attr::Gather::Workflow
        #
        #     aggregator :deep_merge
        #   end
        #
        # @param agg [#call] the aggregator to use
        #
        # @api public
        def aggregator(agg = nil, opts = EMPTY_HASH)
          if agg.nil? && !defined?(@aggregator)
            @aggregator = Aggregators.default
            return @aggregator
          end

          @aggregator = Aggregators.resolve(agg, opts) if agg
          @aggregator
        end
      end
    end
  end
end
