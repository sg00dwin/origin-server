class CommunityApi::Base < RestApi::Base
  self.site = Console.config.community_url || ('https://localhost:8118/' if Rails.env.development?)
  self.proxy = nil

  def self.url_sanitizer
    @url_sanitizer ||= RelativeURLSanitizer.new
  end

  class RelativeURLSanitizer < HTML::WhiteListSanitizer
  	class_attribute :site, :instance_writer => false
  	self.site = CommunityApi::Base.site
  	def process_attributes_for(node, options)
  		super
  		return unless node.name == "a" && node.attributes && node.attributes["href"] && node.attributes["href"].start_with?("/")
  		value = node.attributes["href"].to_s
  		node.attributes["href"] =  URI.join(site, value).to_s
  	end
  end
end
