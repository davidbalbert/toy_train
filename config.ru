require 'no_framework'

MyApp = NoFramework::Application.new do
  root ->(env) { [200, {}, ['Hello, world!']] }
  get '/foo', ->(env) { [200, {}, ['foo']] }
  get '/bar', ->(env) { [200, {}, ['bar']] }
end

run MyApp
