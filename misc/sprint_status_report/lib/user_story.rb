class UserStory
  attr_accessor :data

  def initialize(rest_data)
    @data = rest_data
  end

  def method_missing(method,*args,&block)
    @data.send(method,*args,&block)
  end

  def check_tags(target)
    [tags].flatten.find do |x|
      x.respond_to?(:name) && x.name == target
    end.nil?
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
end
