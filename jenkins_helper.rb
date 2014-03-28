require 'jenkins_api_client'
require 'active_support/core_ext'

class JenkinsHelper
  class << self
    def client
      @client ||= JenkinsApi::Client.new( server_url: ENV["JENKINS_URL"],
                                          username:   ENV["JENKINS_USER"],
                                          password:   ENV["JENKINS_KEY"] )
      @client.logger.level = 4
      @client
    end

    def github_repo(job)
      cfg = Hash.from_xml(client.job.get_config(job))

      if cfg["project"]["properties"] && cfg["project"]["properties"]["com.coravy.hudson.plugins.github.GithubProjectProperty"]
        url = cfg["project"]["properties"]["com.coravy.hudson.plugins.github.GithubProjectProperty"]["projectUrl"]

        { job_name:   job,
          user:       url.split("/")[-2],
          name:       url.split("/")[-1],
          url:        url }
      end
    end

    def build_config(job)
      doc = Nokogiri::XML(client.job.get_config(job))
      script = doc.at_css("builders").at_css("command").children.first.text
      script.sub(JenkinsConfig.script_boilerplate,"")
    end

    def job_exists?(job)
      client.job.list_all.include?(job)
    end

    def job_config(job)
      return nil unless job_exists?(job)
      cfg = JenkinsConfig.new(client.job.get_config(job))
      cfg_hash = { job_name: job }
      %i{github_repo build_script enable_pullrequests}.each do |attribute|
        cfg_hash[attribute] = cfg.send(attribute)
      end

      cfg_hash
    end

    def jenkins_repos
      client.job.list_all.map { |job| github_repo(job) }.compact
    end

    def delete_job(job)
      client.job.delete(job)
    end

    def disabled?(job)
      Nokogiri::XML(client.job.get_config(job)).at_css('disabled').text == "true"
    end

    def create_or_update_job(config)
      if job_exists?(config["job_name"])
        update_job(config)
      else
        create_job(config)
      end
    end

    def update_job(config)
      if config.is_a? Hash
        opts = config
        config = JenkinsConfig.new()
        config.set(opts)
      end

      raise "Instance of JenkinsConfig required to create a new job" unless config.is_a? JenkinsConfig

      client.job.update(config.job_name, config.to_xml)
    end

    def create_job(config)
      if config.is_a? Hash
        opts = config
        config = JenkinsConfig.new()
        config.set(opts)
      end

      raise "Instance of JenkinsConfig required to create a new job" unless config.is_a? JenkinsConfig

      client.job.create(config.job_name, config.to_xml)
    end

    def job_for_repo(user, repo)
      job = jenkins_repos.find{|r| r[:user] == user && r[:name] == repo}
      job[:job_name] if job
    end
  end
end

class JenkinsConfig
  class MissingAttrError < StandardError; end

  REQUIRED_ATTRS      = [:job_name, :github_repo]
  OPTIONAL_ATTRS      = [:build_script, :project_url, :enable_pullrequests]
  ATTRS_WITH_DEFAULTS = []

  SCRIPT_BOILERPLATE = <<-EOF
#!/bin/bash -l
source /var/lib/jenkins/.bashrc
EOF

  attr_accessor :config_document, :job_name
  #[REQUIRED_ATTRS, OPTIONAL_ATTRS].flatten.each { |a| attr_reader a }

  class << self
    def project_template
      xml_string = IO.read(File.dirname(__FILE__) + "/jenkins_templates/default.xml")
      xml_string
    end

    def script_boilerplate
      SCRIPT_BOILERPLATE
    end
  end

  def initialize(config = self.class.project_template)
    self.config_document = Nokogiri::XML(config)
  end

  def set(options = {})
    options.keys.each do |opt|
      self.send(:"#{opt}=", options[opt])
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
    unless @project_url
      repo = github_repo.gsub("git@github.com:","").gsub(/\.git$/,"")
      self.project_url = "https://github.com/#{repo}/" unless @project_url
    end
    config_document.to_xml
  end

  def github_repo=(repo)
    @github_repo = repo
    nodes = @config_document.at_css("userRemoteConfigs").children.select{|c| c.name == "hudson.plugins.git.UserRemoteConfig"}
    nodes.each do |node|
      node.at_css("url").children.first.content = "git@github.com:#{repo}.git"
    end
  end

  def github_repo
    @config_document.at_css("userRemoteConfigs").at_css("url").text
  end

  def project_url=(url)
    @project_url = url
    config_document.at_css("projectUrl").children.first.content = url
  end

  def project_url
    config_document.at_css("projectUrl").children.first.content
  end

  def enable_pullrequests=(enable)
    @enable_pullrequests = enable
    remote_config = @config_document.at_css("userRemoteConfigs")
    pr_node = remote_config.children.find { |c| c.at_css("refspec") && c.at_css("refspec").text == "+refs/pull/*:refs/remotes/origin/pr/*" }

    if enable
      unless pr_node
        node_xml = <<-EOF
<hudson.plugins.git.UserRemoteConfig>
  <name>pr</name>
  <refspec>+refs/pull/*:refs/remotes/origin/pr/*</refspec>
  <url>#{github_repo}</url>
  <credentialsId>7f705fde-c469-4657-974e-6bd1d5cdcaf2</credentialsId>
</hudson.plugins.git.UserRemoteConfig>
        EOF

        remote_config.add_child Nokogiri::XML(node_xml).elements.first
      end
    else
      pr_node.remove if pr_node
    end
  end

  def enable_pullrequests
    remote_config = @config_document.at_css("userRemoteConfigs")
    remote_config.children.any? { |c| c.at_css("refspec") && c.at_css("refspec").text == "+refs/pull/*:refs/remotes/origin/pr/*" }
  end

  def build_script=(script)
    @build_script = script
    node = config_document.at_css("builders").at_css("command").children.first
    node.content = SCRIPT_BOILERPLATE + script
  end

  def build_script
    node = config_document.at_css("builders").at_css("command").children.first
    node.content.sub(SCRIPT_BOILERPLATE,"")
  end
end
