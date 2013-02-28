class BlogPost < RestApi::Base
  include RestApi::Cacheable
  allow_anonymous

  self.site = Console.config.community_url
  self.prefix = '/blogs/'

  schema do
    string :title, :summary, :href
  end

  def date
    @date ||= Time.at(attributes[:date].to_i) rescue Date.now
  end

  cache_method :find_every, :expires_in => 10.minutes

  class << self
    def frontpage
      all(:from => "#{prefix}frontpage.json")
    end
  end
end
