require 'pry'
class UserStory
  attr_accessor :data

  def initialize(rest_data)
    @data = rest_data
  end

  def method_missing(method,*args,&block)
    @data.send(method,*args,&block)
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

  # Dynamically create functions to check what project this is for
  {
    :business?      => "Business Integration",
    :design?        => "Design",
    :documentation? => "Documentation",
    :onpremise?     => "OnPremise",
    :runtime?       => "Runtime",
    :ui?            => "User Interface",
  }.each do |name,val|
    define_method(name) do |match = true|
      (project.name =~ /^#{val}/).nil? != match
    end
  end

  def output
    puts "%s - %s - [%s]" % [formatted_i_d,schedule_state,tags.join(',')]
  end
end
