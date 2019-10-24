# Attr::Gather

[![Actions Status](https://github.com/ianks/attr-gather/workflows/.github/workflows/ruby.yml/badge.svg)](https://github.com/ianks/attr-gather/actions)

A gem for creating simple workflows to enhance entities with extra attributes.
At a high level, `attr-gather` provides a process to sync attributes from many
sources (third party APIs, legacy databases, etc).

## Links

* [API Documentation](http://dry-rb.org/gems/attr-gather/)

## Usage

```ruby
# create a container with task implementations
class UserContainer
  extend Dry::Container::Mixin

  register "fetch_database_info" do |id:, **_attrs|
    repo = UsersRepository.new
    user = repo.by_pk(id).one

    { nickname: user.nickname, email: user.email }
  end

  register "fetch_avatar_info" do |email:, **_attrs|
    api = GravatarAPI.new
    profile = api.get_user_by_email(email)

    { avatar: profile[:avatar] }
  end
end

# define a workflow
class EnhanceUserProfile
  extend Attr::Gather::Workflow

  container UserContainer

  task :fetch_database_info do |t|
    t.depends_on = []
  end

  task :fetch_avatar_info do |t|
    t.depends_on = [:fetch_gravatar_info]
  end
end

# run the workflow
enhancer = EnhanceUserProfile.new
enhancer.call(id: 123) # => { id: 123, email: 'test@test.com', nickname: 'Jay', avatar: 'https://example.com/avatar.png' }
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'attr-gather'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attr-gather

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/ianks/attr-gather. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Attr::Gather project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/ianks/attr-gather/blob/master/CODE_OF_CONDUCT.md).
