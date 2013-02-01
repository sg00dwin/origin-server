class FaqItem < RestApi::Base
  allow_anonymous
  
  self.site = 'https://localhost/'
  self.prefix = '/community/api/v1/faq/'
  
  schema do
    string :id, :href, :name, :updated, :summary, :body
  end
  
  class << self
    def topten
      all :from => "#{prefix}topten.json"
    end
  end
end
