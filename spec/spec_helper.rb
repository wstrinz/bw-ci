ENV['RACK_ENV'] = 'test'

require_relative '../server.rb'
require 'rspec'
require 'rack/test'

include Rack::Test::Methods

def app
  Sinatra::Application
end

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end
