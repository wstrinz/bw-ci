class JobsController < Sinatra::Application
  helpers BWCIHelpers

  get '/enabled_repositories' do
    ensure_authenticated
    content_type :json
    jenkins_repos.to_json
  end

  get '/test_config/:user/:repo' do
    ensure_authenticated
    content_type :json
    test_config(session[:auth_hash], params[:user], params[:repo]).to_json
  end

  get '/job_config/:job' do
    ensure_authenticated
    content_type :json
    job_config(params[:job]).to_json
  end

  get '/build_status/:job' do
    ensure_authenticated
    content_type :json
    build_status(params[:job]).to_json
  end

  get '/jenkins_url' do
    ensure_authenticated
    content_type :json
    {url: ENV["JENKINS_URL"]}.to_json
  end

  post '/enable_job' do
    ensure_authenticated
    content_type :json
    #begin
    enable_job(params[:data])
    {status: :success}.to_json
    #rescue Exception => e
    # {status: :failure, reason: e}.to_json
    #end
  end

  post '/delete_job/:job' do
    ensure_authenticated
    content_type :json
    begin
      delete_job(params[:job])
      {status: :success}.to_json
    rescue Exception => e
      {status: :failure, reason: e}.to_json
    end
  end

  post '/build_job/:job' do
    ensure_authenticated
    content_type :json
    build_job(params[:job])
    {status: :success}
  end

  post '/disable_job/:job' do
    ensure_authenticated
    content_type :json
    disable_job(params[:job])
  end
end
