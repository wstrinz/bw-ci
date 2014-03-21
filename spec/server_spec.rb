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
    let(:expected_config) { {"language"=>"ruby", "rvm"=>["1.9.3", "2.0.0", "jruby-19mode"]} }

    it "retrieves test config from a given repository" do
      get "/test_config/wstrinz/publisci"
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)).to eq(expected_config)
    end
  end

  describe '/enabled_repositories', :vcr do
    let(:expected_repos) { [{"name"=>"bw_poopdeck"}] }

    it "retrieves known repos from jenkins" do
      get "/enabled_repositories"
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)).to eq(expected_repos)
    end
  end
end
