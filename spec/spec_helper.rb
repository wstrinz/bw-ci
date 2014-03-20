ENV['RACK_ENV'] = 'test'

require_relative '../server.rb'
require 'rspec'
require 'rack/test'

include Rack::Test::Methods

def app
  Sinatra::Application
end
