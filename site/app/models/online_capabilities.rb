class OnlineCapabilities < Capabilities::Cacheable
  cache_attribute :plan_upgrade_enabled

  def plan_id
    super || 'freeshift'
  end

  def to_a
    super.map!{ |v| v == 'freeshift' ? nil : v }
  end

  alias_method :plan_upgrade_enabled?, :plan_upgrade_enabled

  protected
    def plan_upgrade_enabled=(s)
      @plan_upgrade_enabled = !!s
    end
end
