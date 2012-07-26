class RestPlan
  attr_accessor :id, :plan_no, :name, :capabilities

  def initialize(id, name, plan_no, capabilities)
    self.id = id
    self.plan_no = plan_no
    self.name = name
    self.capabilities = capabilities
  end

  def to_xml(options={})
    options[:tag_name] = "plan"
    super(options)
  end
end
