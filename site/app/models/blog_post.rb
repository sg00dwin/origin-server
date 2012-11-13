class BlogPost < RestApi::Base
  include RestApi::Cacheable
  allow_anonymous

  self.site = 'https://openshift.redhat.com'
  self.prefix = '/community/blogs/'

  schema do
    string :title, :summary, :href
  end

  def date
    @date ||= Time.at(attributes[:date].to_i)
  end

  cache_method :find_every, :expires_in => 10.minutes

  class << self
    def frontpage
      all(:from => "#{prefix}frontpage.json")
    end
  end
end
