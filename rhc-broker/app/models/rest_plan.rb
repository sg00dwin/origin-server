class RestPlan < OpenShift::Model
  attr_accessor :id, :plan_no, :name, :capabilities, :usage_rates

  def initialize(id, name, plan_no, capabilities, usage_rates)
    self.id = id
    self.plan_no = plan_no
    self.name = name
    self.capabilities = capabilities
    self.usage_rates = usage_rates
  end

  def to_xml(options={})
    options[:tag_name] = "plan"
    super(options)
  end
end
