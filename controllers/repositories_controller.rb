require './server'

class RepositoriesController < Sinatra::Base
  helpers BWCIHelpers

  before do
    ensure_authenticated
  end

  get '/repositories' do
    content_type :json
    repos(session[:auth_hash]).to_json
  end
end

