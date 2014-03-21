require 'yaml'
require 'base64'
require 'octokit'

class GithubHelper
  class << self
    def travis_hash(info_hash, user, repo)

      token = info_hash["credentials"]["token"]
      #user = info_hash["info"]["nickname"]
      client = Octokit::Client.new(oauth_token: token)

      begin
        travis_file = client.contents(user + "/" + repo, path: ".travis.yml")
      rescue Octokit::NotFound
        return false
      end

      YAML.load(Base64.decode64(travis_file.content))
    end

    def repos(info_hash)
      token = info_hash["credentials"]["token"]
      g = Octokit::Client.new(access_token: token)
      user = g.user.login
      g.auto_paginate = true

      user_repos = g.repos(user)

      org_repos = g.org_repos('bendyworks')

      [
        user_repos.map{ |r|
          { name: r.name,
            url: "https://github.com/#{r.full_name}/" }
        }.sort_by{|r| r[:name].downcase},

        org_repos.map{|r|
          { name: r.name,
            url: "https://github.com/#{r.full_name}/" }
        }.sort_by{|r| r[:name].downcase},
      ].flatten
    end
  end
end
