require 'rest-client'
require 'sinatra'
require 'json'
require 'haml'
require 'omniauth'
require 'omniauth-github'
require 'octokit'


helpers do
  def sample_repos
    JSON.parse(IO.read('dev_data/repos.json'))
  end

  def sample_oauth
    IO.read('dev_data/oauth_token')
  end

  def sample_auth_hash
    {
      "credentials" =>
      {
        "token" => sample_oauth
      },
      "info" =>
      {
        "nickname" => "wstrinz"
      }
    }
  end

  def repos(info_hash)
    token = info_hash["credentials"]["token"]
    g = Octokit::Client.new(access_token: token)
    user = g.user.login
    g.auto_paginate = true

    user_repos = g.repos(user)
    #user_repos = []
    #user_list.each_page{|p| p.each{|r| user_repos << r}}

    org_repos = g.org_repos('bendyworks')
    #org_repos = []
    #org_list.each_page{|p| p.each{|r| org_repos << r}}

    [
      user_repos.map{|r| {name: r.name, url: 'placeholder'}},
      org_repos.map{|r| {name: r.name, url: 'placeholder'}},
    ].flatten
  end

  def test_config(info_hash, repo)
    token = info_hash["credentials"]["token"]
    #user = info_hash["info"]["nickname"]
    g = Octokit::Client.new(oauth_token: token)

    travis = GithubHelper.travis_hash(g, repo)
    if travis
      travis
    else
      raise "No Travis config found, others coming soon"
    end
  end

  def authenticate!
    if self.class.development?
      session[:authenticated] = true
      session[:auth_hash] = sample_auth_hash
      redirect '/'
    else
      redirect '/auth/github'
    end
  end
end

configure do
  use Rack::Session::Cookie
  use OmniAuth::Builder do
    user_scopes = 'user,repo,read:repo_hook,write:repo_hook,admin:repo_hook,read:org'
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: user_scopes
  end
  enable :sessions
end

get '/' do
  unless session[:authenticated]
    authenticate!
  else
    @build_script = "rake"
    @@info_hash = session[:auth_hash]
    haml :repos
  end
end

get '/reauth' do
  authenticate!
end

get '/auth/:provider/callback' do
  content_type :json
  # this doesn't work yet. not sure how to get info out of the hash in sinatra yet
  auth_hash = request.env['omniauth.auth']
  puts auth_hash
  session[:authenticated] = true
  session[:auth_hash] = auth_hash
  redirect "/"
end

get '/repositories' do
  content_type :json
  repos(@@info_hash).to_json
end

post '/' do
  puts "got #{params}"

  haml :repos
end
