class RestPlan < OpenShift::Model
  attr_accessor :id, :plan_no, :name, :capabilities, :charges

  def initialize(id, name, plan_no, capabilities, charges)
    self.id = id
    self.plan_no = plan_no
    self.name = name
    self.capabilities = capabilities
    self.charges = charges
  end

  def to_xml(options={})
    options[:tag_name] = "plan"
    super(options)
  end
end
