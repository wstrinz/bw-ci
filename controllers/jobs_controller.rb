module JobsController


  def self.included(base)
    base.extend ClassMethods
    base.add_routes
  end

  module ClassMethods
    def add_routes
      helpers do
        def jenkins_repos
          JenkinsHelper.jenkins_repos
        end

        def job_config(job)
          JenkinsHelper.job_config(job)
        end

        def enable_job(options)
          JenkinsHelper.create_or_update_job(JSON.parse(options))
        end

        def delete_job(job)
          JenkinsHelper.delete_job(job)
        end

        def build_job(job)
          JenkinsHelper.client.job.build(job)
        end

        def disable_job(job)
          JenkinsHelper.client.job.disable(job)
        end

        def build_status(job)
          {status: JenkinsHelper.client.job.get_current_build_status(job)}
        end

        def test_config(info_hash, user, repo)
          job = JenkinsHelper.job_for_repo(user, repo)
          if job
            { type: 'jenkins',
              config: { script: JenkinsHelper.build_config(job) } }
          else
            travis = GithubHelper.travis_hash(info_hash, user, repo)
            if travis
              { type: "travis", config: travis }
            else
              { type: "none" }
              #raise "No Travis config found, others coming soon"
            end
          end
        end
      end

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
  end

end

