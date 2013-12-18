require 'rest-client'
require 'sinatra'

get '/repos' do
	@build_script = "rake"
	@repo = "bendyworks/bw_poopdeck"
  
	erb :hello
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

	erb :post_result
end
__END__
@@ layout
<html>
  <body>
   <%= yield %>
  </body>
</html>

@@ hello
<h3>Hello</h3>
<form action='/repos' method='post' id='repoform'>
	Repository: <input type='text' name='repository' label='repository' size="50" value=<%= @repo %> autofocus>
	<br>
	Build Script: <textarea form='repoform' name='script' cols="40">
<%= @build_script %></textarea>
	<br>
	<br>
	<input type='submit' value='Add to Integrity'>
</form>

@@ post_result
<%= @build_status %><br>
More at <a href=<%= @project_url %> >The project's page</a>
