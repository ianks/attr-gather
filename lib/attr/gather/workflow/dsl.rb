# frozen_string_literal: true

module Attr
  module Gather
    module Workflow
      # DSL for configuring a workflow
      #
      # @api public
      module DSL
        # @api private
        Undefined = Object.new.freeze

        # Defines a task with name and options
        #
        # @param task_name [Symbol] the name of the task
        #
        # @example
        #   class EnhanceUserProfile
        #     include Attr::Gather::Workflow
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
          conf = OpenStruct.new
          yield conf
          tasks << Hash[name: task_name, **opts, **conf.to_h]
          self
        end

        # Defines a task with name and options
        #
        # @param task_name [Symbol] the name of the task
        #
        # @example
        #   class EnhanceUserProfile
        #     include Attr::Gather::Workflow
        #
        #     # ...
        #
        #     fetch :user_info do |t|
        #       t.depends_on = [:fetch_gravatar_info]
        #     end
        #   end
        #
        # Calling `fetch` will yield a task object which you can configure like
        # a PORO. Tasks will be registered for execution in the workflow.
        #
        # @yield [Attr::Gather::Workflow::Task] A task to configure
        #
        # @api public
        alias fetch task

        # Defines a task with name and options
        #
        # @param task_name [Symbol] the name of the task
        #
        # @example
        #   class EnhanceUserProfile
        #     include Attr::Gather::Workflow
        #
        #     # ...
        #
        #     fetch :user_info do |t|
        #       t.depends_on = [:email_info]
        #     end
        #   end
        #
        # Calling `fetch` will yield a task object which you can configure like
        # a PORO. Tasks will be registered for execution in the workflow.
        #
        # @yield [Attr::Gather::Workflow::Task] A task to configure
        #
        # @api public
        alias gather task

        # Defines a task with name and options
        #
        # @param task_name [Symbol] the name of the task
        #
        # @example
        #   class EnhanceUserProfile
        #     include Attr::Gather::Workflow
        #
        #     # ...
        #
        #     step :fetch_user_info do |t|
        #       t.depends_on = [:fetch_gravatar_info]
        #     end
        #   end
        #
        # Calling `step` will yield a task object which you can configure like
        # a PORO. Tasks will be registered for execution in the workflow.
        #
        # @yield [Attr::Gather::Workflow::Task] A task to configure
        #
        # @api public
        alias step task

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
        #     include Attr::Gather::Workflow
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
        #     include Attr::Gather::Workflow
        #
        #     aggregator :deep_merge
        #   end
        #
        # @param agg [#call] the aggregator to use
        #
        # @api public
        def aggregator(agg = nil, opts = EMPTY_HASH)
          @aggregator = if agg.nil? && !defined?(@aggregator)
                          Aggregators.default
                        elsif agg
                          Aggregators.resolve(agg, filter: filter, **opts)
                        else
                          @aggregator
                        end
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
        #     include Attr::Gather::Workflow
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
        def filter(filt = nil, *args, **opts)
          @filter = if filt.nil? && !defined?(@filter)
                      Filters.default
                    elsif filt
                      Filters.resolve(filt, *args, **opts)
                    else
                      @filter
                    end

          aggregator.filter = @filter

          @filter
        end

        # Defines a filter for filtering invalid values with an inline contract
        #
        # This serves as a convenience method for defining a contract filter.
        #
        # @example
        #
        #   class EnhanceUserProfile
        #     include Attr::Gather::Workflow
        #
        #     # Any of the key/value pairs that had validation errors will be
        #     # filtered from the output.
        #     filter_with_contract do
        #        params do
        #          required(:name).filled(:string)
        #          required(:age).value(:integer)
        #        end
        #
        #        rule(:age) do
        #          key.failure('must be greater than 18') if value < 18
        #        end
        #     end
        #   end
        #
        # @return [Dry::Validation::Contract,NilClass]
        # @see https://dry-rb.org/gems/dry-validation
        #
        # @api public
        def filter_with_contract(arg = nil, &blk)
          contract = block_given? ? build_inline_contract_filter(&blk) : arg
          filter(:contract, contract)
        end

        private

        def build_inline_contract_filter(&blk)
          contract_klass = Class.new(Dry::Validation::Contract, &blk)
          contract_klass.new
        end
      end
    end
  end
end
