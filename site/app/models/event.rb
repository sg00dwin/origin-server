class Event < RestApi::Base
  include RestApi::Cacheable
  allow_anonymous

  self.site = 'https://openshift.redhat.com'
  self.prefix = '/community/events/'

  schema do
    string :title, :href
  end

  def date
    @date ||= Time.at(attributes[:date].to_i)
  end

  def city
    @city ||= attributes[:field_event_city_value]
  end

  def state
    @state ||= attributes[:field_event_state_value]
  end

  cache_method :find_every, :expires_in => 10.minutes

  class << self
    def upcoming
      all(:from => "#{prefix}upcoming.json")
    end
  end
end
