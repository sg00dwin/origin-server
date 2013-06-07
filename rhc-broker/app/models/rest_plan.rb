class RestPlan < OpenShift::Model
  attr_accessor :id, :plan_no, :name, :capabilities, :usage_rates, :links

  def initialize(id, name, plan_no, capabilities, usage_rates, url, nolinks=false)
    self.id = id
    self.plan_no = plan_no
    self.name = name
    self.capabilities = capabilities
    self.usage_rates = usage_rates

    unless nolinks
      @links = {
        "GET_#{id.to_s.upcase}_PLAN" => Link.new("Get #{id} plan", "GET", URI::join(url, "plans/#{id}"))
      }
    end
  end

  def to_xml(options={})
    options[:tag_name] = "plan"
    super(options)
  end
end
