module BWCIHelpers
  def ensure_authenticated
    unless authenticated?
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

  def authenticated?
    session[:authenticated]
  end

  def sample_oauth
    if File.exist? "dev_data/oauth_token"
      IO.read('dev_data/oauth_token').strip
    else
      ENV["OAUTH_TOKEN"]
    end
  end

  def sample_auth_hash
    { "credentials" => { "token"    => sample_oauth },
      "info"        => { "nickname" => "wstrinz"    } }
  end


  def logout!
    session.clear
  end

  def sample_repos
    JSON.parse(IO.read('dev_data/repos.json'))
  end

  def repos(info_hash)
    GithubHelper.repos(info_hash)
  end
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
