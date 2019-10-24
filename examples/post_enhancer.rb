# frozen_string_literal: true

require 'dry-container'
require 'attr-gather'
require 'http'

# create the container
class MyContainer
  extend Dry::Container::Mixin

  register 'fetch_post' do |id:, **_attrs|
    res = HTTP.get("https://jsonplaceholder.typicode.com/posts/#{id}")
    post = JSON.parse(res.to_s, symbolize_names: true)

    { title: post[:title], user_id: post[:userId], body: post[:body] }
  end

  register 'fetch_user' do |user_id:, **_attrs|
    res = HTTP.get("https://jsonplaceholder.typicode.com/users/#{user_id}")
    user = JSON.parse(res.to_s, symbolize_names: true)

    { user: { name: user[:name], email: user[:email] } }
  end
end

# define a workflow
class EnhanceUserProfile
  include Attr::Gather::Workflow

  container MyContainer

  task :fetch_post do |t|
    t.depends_on = []
  end

  task :fetch_user do |t|
    t.depends_on = [:fetch_post]
  end
end

# run the workflow
enhancer = EnhanceUserProfile.new
puts JSON.pretty_generate(enhancer.call(id: 1).value!)
