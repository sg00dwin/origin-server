require 'rally_rest_api'
require 'user_story'
require 'queries'

class Sprint
  # Rally Config
  attr_accessor :eng_workspace_oid, :username, :password
  # Calendar related attributes
  attr_accessor :name, :number, :start, :end, :dcut, :dcut_offset
  # Rally related attributes
  attr_accessor :rally, :workspace, :project, :rally_config, :iterations
  # UserStory related attributes
  attr_accessor :stories, :processed, :results
  # Queries to run against US
  #attr_accessor :queries
  attr_accessor :debug

  def initialize(opts)
    opts.each do |k,v|
      send("#{k}=",v)
    end

    @rally = RallyRestAPI.new(
      :username => @username,
      :password => @password
    )

    @stories = get_stories
  end

  def day
    $date ||= Date.today # Allow overriding for testing
    ($date - start.to_date + 1).to_i
  end

  def days_until(num)
    (case num
    when Symbol
      send(num) - start - day + 1
    when Integer
      num - day
    end).to_i
  end

  def show_days(report)
    puts "%s - Starts on %s" % [report.title,report.day]
    puts
    (start..send(:end)).each do |x|
      $date = x
      req = case
            when report.first_day?
              "Start"
            when report.required?
              "  |  "
            else
              ''
            end
      puts "%s (%2d) - %s" % [x,day,req]
    end
    $date = Date.today
  end

  def workspace
    @workspace ||= rally.user.subscription.workspaces.select{|x| x.oid == @eng_workspace_oid }.first
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

  def iterations
    # Get all current iterations for this project
    @iterations ||= rally.find(:iteration, :project => project, :workspace => workspace){
      lte :start_date, Date.today.to_s
      gte :end_date, Date.today.to_s
      not_equal :state, "Accepted"
      not_equal :state, "Committed"
    }
  end

  def start
    @start ||= iterations.map{|x| Date.parse(x.start_date)}.sort.first
  end

  def end
    @end ||= iterations.map{|x| Date.parse(x.end_date)}.sort.last
  end

  def dcut
    @dcut ||= start + dcut_offset
  end

  def number
    name.scan(/\d+/).first.to_i
  end

  def name
    @name ||= (iterations.map do |i|
      i.name
    end.uniq.first)
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

    unless !debug && processed[name]
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
