require 'rest-client'
require 'sinatra'
require 'json'
require 'haml'
require 'omniauth'
require 'omniauth-github'


helpers do
  def sample_repos
    [
      {
        name: "sample",
        url: "http://www.github.com/bendyworks/bw-poopdeck",
        private: true
      }
    ]
  end

  def repos

  end

  def authenticate!
    redirect '/auth/github'
  end
end

configure do
  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  end
  enable :sessions
end

get '/' do
  unless session[:authenticated]
    authenticate!
  else
    @build_script = "rake"

    haml :repos
  end
end

get '/auth/:provider/callback' do
  content_type :json
  auth_hash = request.env['omniauth.auth']
  puts auth_hash
  session[:authenticated] = true
  session[:auth_hash] = auth_hash
  puts auth_hash.to_json
end

get '/repositories' do
  content_type :json
  repos.to_json
end

post '/' do
  puts "got #{params}"

  haml :repos
end
