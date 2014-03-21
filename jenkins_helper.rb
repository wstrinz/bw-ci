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
          url: url }
      end
    end

    def jenkins_repos
      cl = JenkinsApi::Client.new(server_url: ENV['JENKINS_URL'], username: ENV["JENKINS_USER"], password: ENV["JENKINS_KEY"])
      cl.logger.level = 4
      cl.job.list_all.map { |job| github_repo(cl, job) }.compact
    end
  end
end

class JenkinsConfig

  class << self
    def project_template
      xml_string = IO.read(File.Dirname(__FILE__) + "/jenkins_templates/default.xml")
      # create nokogiri document
      Nokogiri::XML(xml_string)
    end
  end

  class MissingAttr < StandardError; end

  REQUIRED_ATTRS      = [:project_name, :github_repo]
  OPTIONAL_ATTRS      = [:build_script, :project_url]
  ATTRS_WITH_DEFAULTS = []

  SCRIPT_BOILERPLATE = <<-EOF
#!/bin/bash -l
source /var/lib/jenkins/.bashrc
  EOF

  [REQUIRED_ATTRS, OPTIONAL_ATTRS].flatten.each { |a| attr_reader a }

  def initialize(options = {})
    [REQUIRED_ATTRS, ATTRS_WITH_DEFAULTS, OPTIONAL_ATTRS].each do |a|
      if options[a]
        self.send(:"#{a}=", options[:a])
      end
    end

    @config_document = self.class.project_template
  end

  def validate!
    REQUIRED_ATTRS.each do |a|
      raise MissingAttr, "Required attribute #{a} is missing" unless self.send(a)
    end
  end

  def to_xml
    validate!
    project_url = "http://github.com/#{github_repo}" unless project_url
    @config_document.to_xml
  end

  def project_name=(name)
    @project_name = name
  end

  def github_repo=(repo)
    @github_repo = repo
    node = @config_document.at_css("userRemoteConfigs").children[1].at_css("url")
    node.children.first.content = "git@github.com:#{github_repo}.git"
  end

  def project_url=(url)
    @project_url = url
    @config_document.at_css("projectUrl").children.first.content = url
  end

  def build_script=(script)
    @build_script = script
    node = @config_document.at_css("builders").at_css("command").children.first
    node.content = SCRIPT_BOILERPLATE + "\n" + script
  end
end
