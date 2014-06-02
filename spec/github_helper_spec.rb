require_relative 'spec_helper'

describe GithubHelper do
  let(:repo) { "wstrinz/Fields-of-Fuel-Server" }
  let(:jenkins_key) { ENV["JENKINS_PUBLIC_KEY"] }
  let(:credentials) do
    token = File.exist?("dev_data/oauth_token") ? IO.read('dev_data/oauth_token').strip : ENV["OAUTH_TOKEN"]
    { "credentials" => { "token"    => token },
      "info"        => { "nickname" => "wstrinz"  } }
  end

  describe ".add_deploy_key" do
    it "adds deploy key to repo" do
      pending "not implemented"
      result = GithubHelper.add_deploy_key(credentials, repo, "jenkins_key_test", jenkins_key)
      expect(result).to eq("asdfa")
    end
  end
end
