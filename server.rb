require 'rest-client'
require 'sinatra/base'
require 'json'
require 'haml'
require 'omniauth'
require 'omniauth-github'
require 'rack/ssl-enforcer'

require_relative 'github_helper'
require_relative 'jenkins_helper'

require_relative 'helpers/bwci_helpers'

require_relative 'controllers/repositories_controller'
require_relative 'controllers/authorization_controller'
require_relative 'controllers/jobs_controller'

class BWCI < Sinatra::Application

  use AuthorizationController
  use RepositoriesController
  use JobsController

  helpers BWCIHelpers

  configure do
    if production?
      use Rack::SslEnforcer
    end
    use OmniAuth::Builder do
      user_scopes = 'user,repo,read:repo_hook,write:repo_hook,admin:repo_hook,read:org'
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: user_scopes
    end
    enable :sessions
    set :session_secret, ENV['SESSION_SECRET']
  end

  get '/' do
    if authenticated?
      @build_script = "rake"
      @user = session[:auth_hash]["info"]["nickname"]
      haml :backbone_repos
    else
      haml :login
    end
  end

  run! if $0 == app_file
end
