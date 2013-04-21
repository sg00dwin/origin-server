class OnlineCapabilities < Capabilities::Cacheable
  cache_attribute :plan_upgrade_enabled

  def plan_id
    super || 'free'
  end

  def to_a
    super.tap do |arr| 
      i = self.class.attrs.index(:plan_id) 
      arr[i] = nil if arr[i] == 'free'
    end
  end

  alias_method :plan_upgrade_enabled?, :plan_upgrade_enabled

  protected
    def plan_upgrade_enabled=(s)
      @plan_upgrade_enabled = !!s
    end
end
