require_relative 'spec_helper'

describe "bw-ci app" do
  def auth!
    get '/'
  end

  it "works" do
    get '/'
    expect(last_response).to be_ok
  end

  describe "/repositories" do
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
end
