
require_relative 'spec_helper'

describe JenkinsHelper, :vcr do
  describe ".github_repo" do
    it "returns repo data"
  end

  describe ".jenkins_repo" do
    it "returns list of enabled repos"
  end
end

describe JenkinsConfig, :vcr do
  let(:options) { { job_name: 'test_project',
                    github_repo:  'wstrinz/publisci',
                    build_script: "bundle \n bundle exec rake" } }

  it "creates a config" do
    cfg = JenkinsConfig.new(options)
    expect(cfg.job_name).to eq(options[:job_name])
    expect(cfg.validate!).to be_true
  end

  describe "submits valid config to jenkins" do
    let(:config) { JenkinsConfig.new(options) }

    before do
      begin
        JenkinsHelper.client.job.delete(config.job_name)
      rescue
      end
    end

    after do
      begin
        JenkinsHelper.client.job.delete(config.job_name)
      rescue
      end
    end

    it do
      expect(JenkinsHelper.create_job(config)).to eq("200")
    end
  end
end
