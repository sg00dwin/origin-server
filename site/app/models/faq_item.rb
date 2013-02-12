class FaqItem < RestApi::Base
  allow_anonymous

  self.site = Rails.application.config.acct_help_faq_site
  self.prefix = Rails.application.config.acct_help_faq_prefix
  self.proxy = nil

  schema do
    string :id, :href, :name, :updated, :summary, :body
  end

  class << self
    def topten
      find :all, :from => "#{self.prefix}/topten.json"
    end

    def all
      find :all, :from => "#{self.prefix}.json"
    end

  end
end
