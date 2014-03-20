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

    org_repos = g.org_repos('bendyworks')

    [
      user_repos.map{|r| {name: r.name, url: "https://www.github.com/#{r.full_name}"}},
      org_repos.map{|r| {name: r.name, url: "https://www.github.com/#{r.full_name}"}},
    ].flatten
  end

  def jenkins_repos
    [{name: "bw_poopdeck"}]
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

  def ensure_authenticated
    unless session[:authenticated]
      authenticate!
    end
  end

  def authenticate!
    unless self.class.production?
      session[:authenticated] = true
      session[:auth_hash] = sample_auth_hash
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
  ensure_authenticated
  @build_script = "rake"
  haml :repos
end

get '/reauth' do
  authenticate!
  redirect '/'
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
  ensure_authenticated
  content_type :json
  repos(session[:auth_hash]).to_json
end

get '/enabled_repositories' do
  ensure_authenticated
  content_type :json
  jenkins_repos.to_json
end

get '/travis_config' do
  ensure_authenticated
end

post '/' do
  puts "got #{params}"

  haml :repos
end
