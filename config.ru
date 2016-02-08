require 'no_framework'

class BlogController < NoFramework::Controller
  def index
    <<~END
    1. First post
    2. Second post
    3. getting old
    END
  end

  def print_params
    params.to_s
  end
end

MyApp = NoFramework::Application.new do
  root ->(env) { [200, {}, ['Hello, world!']] }
  get '/foo', ->(env) { [200, {}, ['foo']] }
  get '/blog', to: 'blog#index'
  get '/params', to: 'blog#print_params'
end

run MyApp
