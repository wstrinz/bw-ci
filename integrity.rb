require 'rest-client'
require 'sinatra'
require 'haml'

get '/repos' do
	@build_script = "rake"
	@repo = "bendyworks/bw_poopdeck"

	haml :hello
end

get '/bendyworks' do

end

get '/' do
  redirect '/repos'
end

post '/repos' do

	repo = params[:repository]
	build_script = params[:script]

	url = "http://#{ENV["INTEGRITY_ADMIN"]}:#{ENV["INTEGRITY_PASSWORD"]}@50.116.40.22:9292/"

  project_name = repo

 	RestClient.post url, {
    "project_data" =>
      { "name" => project_name,
        "uri" => "git@github.com:#{repo}.git",
        "branch" => "master",
 	      "command" => build_script,
        "artifacts" => "",
        "public" => "1"
      }
  }

  @project_url = "#{url}#{project_name.gsub("/","-").gsub("_","-")}"
  RestClient.post "#{@project_url}/builds", "build it yo"

  @build_status = RestClient.get "#{@project_url}.json"

	haml :post_result
end
