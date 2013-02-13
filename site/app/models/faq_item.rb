class FaqItem < RestApi::Base
  allow_anonymous

  self.site = 'https://localhost:8118/'
  self.prefix = '/api/v1/faq'

  # TODO:  Get site and proxy info from the config
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
