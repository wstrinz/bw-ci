require 'rest-client'
require 'sinatra'
require 'json'
require 'haml'

helpers do
  def repos
    [
      {
        name: "sample",
        url: "http://www.github.com/bendyworks/bw-poopdeck",
        private: true
      }
    ]
  end
end

get '/' do
	@build_script = "rake"

	haml :repos
end

get '/repositories' do
  content_type :json
  repos.to_json
end

post '/' do
  puts "got #{params}"

  haml :repos
end
