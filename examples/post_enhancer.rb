# frozen_string_literal: true

require 'dry-container'
require 'dry-validation'
require 'attr-gather'
require 'http'

# create the container
class MyContainer
  extend Dry::Container::Mixin

  register :fetch_post do |id:, **_attrs|
    res = HTTP.get("https://jsonplaceholder.typicode.com/posts/#{id}")
    post = JSON.parse(res.to_s, symbolize_names: true)

    { title: post[:title], user_id: post[:userId], body: post[:body] }
  end

  register :fetch_user_from_buggy_api do |*|
    { user: { email: 'invalidemail' } }
  end

  register :fetch_user do |user_id:, **_attrs|
    res = HTTP.get("https://jsonplaceholder.typicode.com/users/#{user_id}")
    user = JSON.parse(res.to_s, symbolize_names: true)

    { user: { name: user[:name], email: user[:email] } }
  end

  register :email_info do |user:, **_attrs|
    res = HTTP.get("https://api.trumail.io/v2/lookups/json?email=#{user[:email]}")
    info = JSON.parse(res.to_s, symbolize_names: true)

    { user: { email_info: { deliverable: info[:deliverable], free: info[:free] } } }
  end

  register :gravatar_image do |user:, **_attrs|
    require 'digest/md5'
    email_address = user[:email].downcase
    hash = Digest::MD5.hexdigest(email_address)
    image_url = "https://www.gravatar.com/avatar/#{hash}"

    { user: { gravatar: image_url } }
  end
end

# define a validation contract
class UserContract < Dry::Validation::Contract
  params do
    required(:user_id).filled(:integer)

    optional(:user).hash do
      optional(:name).filled(:string)
      optional(:email).filled(:string)
      optional(:gravatar).filled(:string)
      optional(:email_info).hash do
        optional(:deliverable).filled(:bool?)
        optional(:free).filled(:bool?)
      end
    end
  end
end

# define a workflow
class EnhanceUserProfile
  include Attr::Gather::Workflow

  # contains all the task implementations
  container MyContainer

  # perform a deep merge of the task outputs for the result
  aggregator :deep_merge

  # filter out invalid values using a Dry::Validation::Contract
  filter :contract, UserContract.new

  task :fetch_post do |t|
    t.depends_on = []
  end

  task :fetch_user_from_buggy_api do |t|
    t.depends_on = [:fetch_post]
  end

  task :fetch_user do |t|
    t.depends_on = [:fetch_post]
  end

  # will run in parallel
  task :email_info do |t|
    t.depends_on = [:fetch_user]
  end

  # will run in parallel
  task :gravatar_image do |t|
    t.depends_on = [:fetch_user]
  end
end

# run the workflow
enhancer = EnhanceUserProfile.new

puts
puts 'Runing workflow...'
puts
puts 'Result'
puts '======'
pp enhancer.call(id: 12).value!

# fun fact: you can preview as svg!
puts
print 'Would you like to preview the workflow as SVG? (y/n): '
exit 0 unless gets.strip == 'y'

begin
  enhancer.to_dot(preview: true)
rescue SignalException
  puts 'Done!'
rescue StandardError
  abort 'Could not render SVG, please make sure you have ' \
        'graphviz installed (brew install graphviz), then retry'
end
