require 'rally_rest_api'
require 'user_story'

class RallyHelper
  # Rally Config
  attr_accessor :eng_workspace_oid, :username, :password
  # Rally related attributes
  attr_accessor :rally_rest_api, :workspace, :project

  def initialize(opts)
    opts.each do |k,v|
      send("#{k}=",v)
    end

    @rally_rest_api = RallyRestAPI.new(
      :username => @username,
      :password => @password
    )
  end

  def workspace
    @workspace ||= rally_rest_api.user.subscription.workspaces.select{|x| x.oid == @eng_workspace_oid }.first
  ensure
    # Verify we have access to the Engineering Workspace
    unless @workspace
      puts "You do not have access to the Engineering workspace"
      puts "Please send this error to libra-devel@redhat.com for support"
      exit 1
    end
  end
  
  def project
    # Find the OpenShift 2.0 project
    @project ||= workspace.projects.select{|p| p.name == "OpenShift 2.0"}.compact.first
  end

  def get_stories
    # Find all stories for this iteration
    rally_rest_api.find(:hierarchical_requirements, :project => project, :fetch => true){
      equal 'ScheduleState', 'Defined'
    }.map{|x| UserStory.new(x)}
  end

  private
  def method_missing(method,*args,&block)
    begin
      case method.to_s
      when /^not_/
        meth = method.to_s.scan(/not_(.*)/).flatten.first.to_sym
        send(meth,false)
      else
        super
      end
    rescue ArgumentError
      super
    end
  end
end
