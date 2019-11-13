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
          @aggregator = Aggregators.resolve(agg, filter: filter, **opts) if agg

          @aggregator || Aggregators.default
        end

        # Defines a filter for filtering out invalid values
        #
        # When aggregating data from many sources, it is hard to reason about
        # all the ways invalid data will be returned. For example, if you are
        # pulling data from a spreadsheet, there will often be typos, etc.
        #
        # Defining a filter allows you to declaratively state what is valid.
        # attr-gather will use this definition to automatically filter out
        # invalid values, so they never make it into your system.
        #
        # Filtering happens during each step of the workflow, which means that
        # every Task will receive validated input that you can rely on.
        #
        # @example
        #   class UserContract < Dry::Validation::Contract do
        #     params do
        #       optional(:id).filled(:integer)
        #       optional(:email).filled(:str?, format?: /@/)
        #     end
        #   end
        #
        #   class EnhanceUserProfile
        #     extend Attr::Gather::Workflow
        #
        #     # Any of the key/value pairs that had validation errors will be
        #     # filtered from the output.
        #     filter :contract, UserContract.new
        #   end
        #
        # @param filt [Symbol] the name filter to use
        # @param args [Array<Object>] arguments for initializing the filter
        #
        # @api public
        def filter(filt = nil, *args)
          if filt.nil? && !defined?(@filter)
            @filter = Filters.default
            return @filter
          end

          @filter = Filters.resolve(filt, *args) if filt
          @filter
        end
      end
    end
  end
end
