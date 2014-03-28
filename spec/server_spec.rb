require_relative 'spec_helper'

describe "bw-ci app" do
  def auth!
    get '/'
  end

  it "works", :vcr do
    get '/'
    expect(last_response).to be_ok
  end

  describe "/repositories", :vcr do
    before do
    end

    it "retrieves repo list" do
      auth!
      get "/repositories"
      repos = JSON.parse(last_response.body)
      expect(repos).not_to be_nil
    end

    describe "includes repos" do
      let(:repos) do
        auth!
        get "/repositories"
        JSON.parse(last_response.body)
      end

      it "includes private repos" do
        expect(repos.select{|r| r["name"] == "bw_poopdeck"}).not_to be_nil
      end
    end
  end

  describe "/test_config", :vcr do
    let(:expected_config) { { "type"    => "travis",
                              "config"  => { "language" => "ruby",
                                             "rvm"      => ["1.9.3", "2.0.0", "jruby-19mode"] } } }

    it "retrieves test config from a given repository" do
      get "/test_config/wstrinz/publisci"
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)).to eq(expected_config)
    end
  end

  describe '/enabled_repositories', :vcr do
    let(:expected_repos) { [{ "job_name"   => "Poopdeck",
                              "user"       => "bendyworks",
                              "name"       => "bw_poopdeck",
                              "url"        => "https://github.com/bendyworks/bw_poopdeck/" }] }

    it "retrieves known repos from jenkins" do
      get "/enabled_repositories"
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)).to eq(expected_repos)
    end
  end

  describe '/job_config', :vcr do
    let(:expected_config) { { job_name:             "Poopdeck",
                              github_repo:          "git@github.com:bendyworks/bw_poopdeck.git",
                              build_script:         JenkinsHelper.build_config("Poopdeck"),
                              enable_pullrequests:  true } }

    it 'retrieves project config as json' do
      get "/job_config/Poopdeck"
      expect(last_response.body).to eq(expected_config.to_json)
    end

    it 'sends null for nonexistant jobs' do
      get "/job_config/NotAJob"
      expect(last_response.body).to eq(nil.to_json)
    end
  end

  describe '/enable_job', :vcr do
    let(:job_config) { {  job_name:             "test_enable_job",
                          github_repo:          "bendyworks/bw_poopdeck",
                          build_script:         JenkinsHelper.build_config("Poopdeck"),
                          enable_pullrequests:  true } }

    before(:all) do
      JenkinsHelper.client.job.delete("test_enable_job") rescue nil
    end

    after(:all) do
      JenkinsHelper.client.job.delete("test_enable_job") rescue nil
    end

    it "creates a job if none exist" do
      post '/enable_job', data: job_config.to_json
      expect(last_response.status).to eq(200)
    end

    it "updates job config if exists" do
      new_config = job_config.clone
      new_config[:build_script] = "do nothing"
      post '/enable_job', data: new_config.to_json
      expect(last_response.status).to eq(200)

      get '/job_config/test_enable_job'
      data = JSON.parse(last_response.body)
      expect(data["build_script"]).to eq(new_config[:build_script])
    end
  end

  describe '/disable_job', :vcr do
    before(:all) do
      @job_name = "test_disable_job"
      create_test_job(job_name: @job_name)
    end

    after(:all) do
      destroy_test_job(@job_name)
    end

    it "disables a job" do
      expect(JenkinsHelper.disabled?(@job_name)).to be_false
      post "/disable_job/#{@job_name}"
      expect(last_response.status).to eq(200)
      expect(JenkinsHelper.disabled?(@job_name)).to be_true
    end
  end

  describe '/delete_job', :vcr do
    before(:all) do
      @job_name = "test_delete_job"
      create_test_job(job_name: @job_name)
    end

    after(:all) do
      destroy_test_job(@job_name)
    end

    it "deletes job from jenkins" do
      post "/delete_job/#{@job_name}"
      expect(last_response.status).to eq(200)

      get '/enabled_repositories'
      job_exists = JSON.parse(last_response.body).any?{|r| r["job_name"] == @job_name}
      expect(job_exists).to be_false
    end
  end

  describe "/build_job", :vcr do
    before(:all) do
      @job_name = "test_build_job"
      create_test_job(job_name: @job_name)
    end

    after(:all) do
      destroy_test_job(@job_name)
    end

    it "triggers a build" do
      post "/build_job/#{@job_name}"
      expect(last_response.status).to eq(200)

      # TODO: figure out a way to check this that doesn't slow down tests
      # expect(JenkinsHelper.client.job.get_current_build_number(@job_name)).to eq(1)
    end
  end

  describe "/build_status" do
    it "returns project build status" do
      get "/build_status/Poopdeck"
      expect(last_response.body).to eq({status: "success"}.to_json)
    end
  end
end
