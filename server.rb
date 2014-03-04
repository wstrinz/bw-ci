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

  def repos(info_hash)
    token = info_hash["credentials"]["token"]
    user = info_hash["info"]["nickname"]
    g = Github.new(oauth_token: token)

    user_list = g.repos.list user
    user_repos = []
    user_list.each_page{|p| p.each{|r| user_repos << r}}

    org_list = g.repos.list org: 'bendyworks'
    org_repos = []
    org_list.each_page{|p| p.each{|r| org_repos << r}}

    [
      user_repos.map{|r| {name: r.name, url: 'placeholder'}},
      org_repos.map{|r| {name: r.name, url: 'placeholder'}},
    ].flatten
  end

  def authenticate!
    redirect '/auth/github'
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
