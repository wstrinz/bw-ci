require './server'

class RepositoriesController < Sinatra::Base
  helpers BWCIHelpers

  get '/repositories' do
    ensure_authenticated
    content_type :json
    repos(session[:auth_hash]).to_json
  end
end

