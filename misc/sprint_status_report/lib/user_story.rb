class UserStory
  attr_accessor :data

  def initialize(rest_data)
    @data = rest_data
    @projects = {
      :business?      => "Business Integration",
      :design?        => "Design",
      :documentation? => "Documentation",
      :onpremise?     => "OnPremise",
      :runtime?       => "Runtime",
      :ui?            => "User Interface",
    }
  end

  def method_missing(method,*args,&block)
    if (val = @projects[method])
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
