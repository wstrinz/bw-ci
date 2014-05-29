class JobsController < Sinatra::Application
  helpers BWCIHelpers

  before do
    ensure_authenticated
  end

  get '/enabled_repositories' do
    content_type :json
    JenkinsHelper.jenkins_repos.to_json
  end

  get '/test_config/:user/:repo' do
    content_type :json
    test_config(session[:auth_hash], params[:user], params[:repo]).to_json
  end

  get '/job_config/:job' do
    content_type :json
    JenkinsHelper.job_config(params[:job]).to_json
  end

  get '/build_status/:job' do
    content_type :json
    JenkinsHelper.build_status(params[:job]).to_json
  end

  get '/jenkins_url' do
    content_type :json
    { url: ENV["JENKINS_URL"] }.to_json
  end

  post '/enable_job' do
    content_type :json
    #begin
    JenkinsHelper.enable_job(params[:data])
    { status: :success }.to_json
    #rescue Exception => e
    # {status: :failure, reason: e}.to_json
    #end
  end

  post '/delete_job/:job' do
    content_type :json
    begin
      JenkinsHelper.delete_job(params[:job])
      { status: :success }.to_json
    rescue Exception => e
      { status: :failure, reason: e }.to_json
    end
  end

  post '/build_job/:job' do
    content_type :json
    JenkinsHelper.build_job(params[:job])
    { status: :success }
  end

  post '/disable_job/:job' do
    content_type :json
    JenkinsHelper.disable_job(params[:job])
  end
end
