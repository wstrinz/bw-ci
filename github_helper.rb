require 'yaml'
require 'base64'
require 'octokit'

class GithubHelper
  class << self
    def travis_hash(client, repo)
      begin
        travis_file = client.contents(repo, path: ".travis.yml")
      rescue Octokit::NotFound
        return false
      end

      YAML.load(Base64.decode64(travis_file.content))
    end
  end
end
