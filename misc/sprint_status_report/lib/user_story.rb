class UserStory
  attr_accessor :data

  def initialize(rest_data)
    @data = rest_data
  end

  def method_missing(method,*args,&block)
    if (val = CONFIG.projects[method])
      args[0] ||= true
      is_project?(val,args.first)
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
    (project.name =~ /^#{val}/).nil? != match
  end

  def output
    puts "%s - %s - [%s]" % [formatted_i_d,schedule_state,tags.join(',')]
  end
end
