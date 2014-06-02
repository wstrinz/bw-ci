
require_relative 'spec_helper'

describe JenkinsHelper, :vcr do
  describe '.github_repo' do
    it 'returns repo data' do
      expect(JenkinsHelper.github_repo("Poopdeck")[:name]).to eq("bw_poopdeck")
    end
  end

  describe '.jenkins_repos' do
    it 'returns list of enabled repos' do
      expect(JenkinsHelper.jenkins_repos.any?{|r| r[:name] == "bw_poopdeck"}).to be_true
    end
  end

  describe '.job_for_repo' do
    it 'returns jenkins job name for a given repo' do
      JenkinsHelper.job_for_repo('bendyworks', 'bw_poopdeck').should == "Poopdeck"
    end
  end

  describe '.build_config' do
    let(:expected) { "rvm use 2.0.0\ncp config/credentials.yml.example config/credentials.yml\ncp config/database.yml.example config/database.yml\nbundle\nbundle exec rake db:drop db:create db:migrate\nbundle exec rake" }
    it 'returns build_config for a given job' do
      JenkinsHelper.build_config('Poopdeck').should == expected
    end
  end

  describe '.jobs' do
    let(:expected) { { job_name: "Poopdeck",
                       github_repo: 'git@github.com:bendyworks/bw_poopdeck.git',
                       build_script: 'Not tested',
                       build_status: 'success',
                       enable_pullrequests: true } }

    it 'returns job models' do
      jobs = JenkinsHelper.jobs
      expect(jobs.size > 1).to be_true

      poopdeck_job = jobs.find{|j| j[:job_name] == 'Poopdeck'}
      (expected.keys - [:build_script]).each do |sym|
        expect(poopdeck_job[sym]).to eq(expected[sym])
      end
    end
  end
end

describe JenkinsConfig, :vcr do
  let(:options) { { job_name: 'test_project',
                    github_repo:  'wstrinz/publisci',
                    build_script: "bundle \n bundle exec rake",
                    enable_pullrequests: false } }

  it "creates a config" do
    cfg = JenkinsConfig.new()
    cfg.set(options)
    expect(cfg.job_name).to eq(options[:job_name])
    expect(cfg.validate!).to be_true
  end

  describe "submits valid config to jenkins" do
    let(:config) { JenkinsConfig.new() }

    before do
      JenkinsHelper.client.job.delete(config.job_name) rescue nil
      config.set(options)
    end

    after do
      JenkinsHelper.client.job.delete(config.job_name) rescue nil
    end

    it do
      expect(JenkinsHelper.create_job(config)).to eq("200")
    end
  end
end
