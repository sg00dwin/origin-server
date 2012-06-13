require 'rally_rest_api'
require 'calendar'
require 'user_story'

class Sprint
  # Calendar related attributes
  attr_accessor :name, :day, :number, :start, :end, :dcut, :calendar
  # Rally related attributes
  attr_accessor :rally, :workspace, :project, :rally_config
  # UserStory related attributes
  attr_accessor :stories, :processed, :results
  # Queries to run against US
  attr_accessor :queries

  def initialize(opts)
    opts.each do |k,v|
      send("#{k}=",v)
    end

    @queries = {
      :needs_tasks => {
        :function => lambda{|x| x.tasks.nil? }
      },
      :blocked => {
        :function => lambda{|x| x.blocked == "true" }
      },
      :needs_qe => {
        :function => lambda{|x| !x.design? && x.check_tags('no-qe') }
      },
      :qe_ready => {
        :parent => :needs_qe,
        :function => lambda{|x| x.check_notes(/(\[libra-qe\]|tcms|QE)/) }
      },
      :approved => {
        :parent => :not_rejected,
        :function => lambda{|x| !x.check_tags('TC-approved') }
      },
      :rejected => {
        :parent => :qe_ready,
        :function => lambda{|x| !x.check_tags('TC-rejected') }
      }
    }
  end

  # Parse the calendar
  def calendar=(calendar)
    SprintCalendar.new(calendar).sprint_args.each do |k,v|
      send("#{k}=",v)
    end
  end

  # Log in to Rally
  def rally_config=(config)
    @rally = RallyRestAPI.new(
      :username => config[:username],
      :password => config[:password]
    )

    @workspace = rally.user.subscription.workspaces.select{|x| x.oid == config[:eng_workspace_oid] }.first

    # Verify we have access to the Engineering Workspace
    unless @workspace
      puts "You do not have access to the Engineering workspace"
      puts "Please send this error to libra-devel@redhat.com for support"
      exit 1
    end

    # Find the OpenShift 2.0 project
    @project = workspace.projects.select{|p| p.name == "OpenShift 2.0"}.compact.first

    # Fetch stories after logging in
    @stories = get_stories
  end

  def title(short = false)
    str = "Report for %s: Day %d" % [name,day]
    str << " (%s - %s)" % [start,self.end] unless short
    str
  end

  def get_stories
    # Reset processed status
    @processed = {}
    @results = {}

    # For some reason we have to define this locally to this function to work in find
    iteration = name

    # Find all stories for this iteration
    rally.find(:hierarchical_requirements, :project => project, :fetch => true){
      equal 'iteration.name', iteration
    }.map{|x| UserStory.new(x)}
  end

  def find(name, match = true)
    query = queries[name]
    where = stories
    if parent = query[:parent]
      where = send(parent)
    end

    unless processed[name]
      retval = where.partition do |x|
        query[:function].call(x)
      end

      results[name] = {
        true  => retval[0],
        false => retval[1]
      }
    end

    results[name][match]
  ensure
    processed[name] = true
  end

  private
  def method_missing(method,*args,&block)
    begin
      case method
      when *queries.keys
        find(method,*args)
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
