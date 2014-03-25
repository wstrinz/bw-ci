require 'jenkins_api_client'
require 'active_support/core_ext'

class JenkinsHelper
  class << self
    def client
      @client ||= JenkinsApi::Client.new( server_url: ENV['JENKINS_URL'],
                              username:   ENV["JENKINS_USER"],
                              password:   ENV["JENKINS_KEY"] )
      @client.logger.level = 4
      @client
    end

    def github_repo(job)
      cfg = Hash.from_xml(client.job.get_config(job))

      if cfg["project"]["properties"] && cfg["project"]["properties"]["com.coravy.hudson.plugins.github.GithubProjectProperty"]
        url = cfg["project"]["properties"]["com.coravy.hudson.plugins.github.GithubProjectProperty"]["projectUrl"]

        { job:  job,
          user: url.split("/")[-2],
          name: url.split("/")[-1],
          url: url }
      end
    end

    def build_config(job)
      doc = Nokogiri::XML(client.job.get_config(job))
      script = doc.at_css("builders").at_css("command").children.first.text
      script.sub(JenkinsConfig.script_boilerplate,"")
    end

    def jenkins_repos
      client.job.list_all.map { |job| github_repo(job) }.compact
    end

    def create_job(config)
      if config.is_a? Hash
        config = JenkinsConfig.new(config)
      end

      raise "Instance of JenkinsConfig required to create a new job" unless config.is_a? JenkinsConfig

      client.job.create(config.job_name, config.to_xml)
    end

    def job_for_repo(user, repo)
      job = jenkins_repos.find{|r| r[:user] == user && r[:name] == repo}
      job[:job] if job
    end
  end
end

class JenkinsConfig


  class MissingAttrError < StandardError; end

  REQUIRED_ATTRS      = [:job_name, :github_repo]
  OPTIONAL_ATTRS      = [:build_script, :project_url]
  ATTRS_WITH_DEFAULTS = []

  SCRIPT_BOILERPLATE = <<-EOF
#!/bin/bash -l
source /var/lib/jenkins/.bashrc
EOF

  attr_accessor :config_document
  [REQUIRED_ATTRS, OPTIONAL_ATTRS].flatten.each { |a| attr_reader a }

  class << self
    def project_template
      xml_string = IO.read(File.dirname(__FILE__) + "/jenkins_templates/default.xml")
      # create nokogiri document
      Nokogiri::XML(xml_string)
    end

    def script_boilerplate
      SCRIPT_BOILERPLATE
    end
  end

  def initialize(options = {})
    self.config_document = self.class.project_template

    all_attrs.each do |a|
      if options[a]
        self.send(:"#{a}=", options[a])
      end
    end

  end

  def all_attrs
    [REQUIRED_ATTRS, ATTRS_WITH_DEFAULTS, OPTIONAL_ATTRS].flatten
  end

  def validate!
    REQUIRED_ATTRS.each do |a|
      raise MissingAttrError, "Required attribute #{a} is missing" unless self.send(a)
    end

    true
  end

  def to_xml
    validate!
    self.project_url = "http://github.com/#{github_repo}" unless project_url
    config_document.to_xml
  end

  def job_name=(name)
    @job_name = name
  end

  def github_repo=(repo)
    @github_repo = repo
    node = @config_document.at_css("userRemoteConfigs").children[1].at_css("url")
    node.children.first.content = "git@github.com:#{github_repo}.git"
  end

  def project_url=(url)
    @project_url = url
    config_document.at_css("projectUrl").children.first.content = url
  end

  def build_script=(script)
    @build_script = script
    node = config_document.at_css("builders").at_css("command").children.first
    node.content = SCRIPT_BOILERPLATE + script
  end
end
