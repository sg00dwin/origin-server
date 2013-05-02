class FaqItem < CommunityApi::Base
  include RestApi::Cacheable
  allow_anonymous

  self.prefix = '/api/v1/faq'

  schema do
    string :id, :href, :name, :updated, :summary, :body
  end

  cache_method :topten, :expires_in => 10.minutes
  cache_method :all, :expires_in => 10.minutes

  class << self
    def topten
      clean(find(:all, :from => "#{self.prefix}/topten.json"))
    end

    def all
      clean(find(:all, :from => "#{self.prefix}.json"))
    end

    private

    def clean(faqs)
      faqs.collect do |faq|
        h = ActionController::Base.helpers

        faq.name = h.sanitize faq.name
        faq.body = self.url_sanitizer.sanitize faq.body
        faq.summary = self.url_sanitizer.sanitize faq.summary

        faq
      end
    end

  end
end
