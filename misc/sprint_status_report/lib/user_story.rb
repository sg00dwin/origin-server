class UserStory
  attr_accessor :data

  def initialize(rest_data)
    @data = rest_data
  end

  def method_missing(method,*args,&block)
    case method
    when *CONFIG.projects.keys
      args[0] ||= true
      is_project?(method,args.first)
    when *CONFIG.states.keys
      check_state(method)
    else
      @data.send(method,*args,&block)
    end
  end

  def check_tags(target)
    if tags.nil?
      false
    else
      tags.map{|x| x.to_s }.include?(target)
    end
  end

  def check_notes(regex)
    notes =~ regex
  end

  def is_project?(val,match = true)
    val = CONFIG.projects[val]
    (project.name =~ /^#{val}/).nil? != match
  end

  def check_state(val)
    schedule_state == CONFIG.states[val]
  end

  def output
    puts "%s - %s - [%s]" % [formatted_i_d,schedule_state,tags.join(',')]
  end
end
