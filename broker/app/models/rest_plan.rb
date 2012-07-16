class RestPlan
  attr_accessor :id, :plan_no, :name
  def initialize(id, name, plan_no)
    self.id = id
    self.plan_no = plan_no
    self.name = name
  end

  def to_xml(options={})
    options[:tag_name] = "plan"
    super(options)
  end
end