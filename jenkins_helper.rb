require 'jenkins_api_client'
require 'active_support/core_ext'

class JenkinsHelper
  class << self
    def github_repo(jenkins_client, project)
      cfg = Hash.from_xml(jenkins_client.job.get_config(project))
      if cfg["project"]["properties"] && cfg["project"]["properties"]["com.coravy.hudson.plugins.github.GithubProjectProperty"]
        url = cfg["project"]["properties"]["com.coravy.hudson.plugins.github.GithubProjectProperty"]["projectUrl"]
        { user: url.split("/")[-2],
          name: url.split("/")[-1],
          url: url
        }
      end
    end

    def jenkins_repos
      cl = JenkinsApi::Client.new(server_url: ENV['JENKINS_URL'], username: ENV["JENKINS_USER"], password: ENV["JENKINS_KEY"])
      cl.logger.level = 4
      cl.job.list_all.map { |job| github_repo(cl, job) }.compact
    end
  end
end
