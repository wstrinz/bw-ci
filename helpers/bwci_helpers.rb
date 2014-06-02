module BWCIHelpers
  def ensure_authenticated
    authenticate! unless authenticated?
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

  def render_app_if_authenticated
    if authenticated?
      @build_script = "rake"
      @user = session[:auth_hash]["info"]["nickname"]
      haml :backbone_repos
    else
      haml :login
    end
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
