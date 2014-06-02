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
  use Rack::Logger

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
    render_app_if_authenticated
  end

  get '*' do
    request.logger.info "fallthrough route"
    render_app_if_authenticated
  end

  run! if $0 == app_file
end
