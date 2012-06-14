class UserStory
  attr_accessor :data

  def initialize(rest_data)
    @data = rest_data
  end

  def method_missing(method,*args,&block)
    @data.send(method,*args,&block)
  end

  def check_tags(target)
    tags.map{|x| x.to_s }.include?(target)
  end

  def check_notes(regex)
    notes =~ regex
  end

  def design?(match = true)
    check_project("Design",match)
  end

  def ui?(match = true)
    check_project("User Interface",match)
  end

  def runtime?(match = true)
    check_project("Runtime",match)
  end

  def business?(match = true)
    check_project("Business Integration",match)
  end

  def check_project(name,match)
    (project.name =~ /^#{name}/).nil? != match
  end

  def output
    puts "%s - %s - [%s]" % [formatted_i_d,schedule_state,tags.join(',')]
  end
end
