class CommunityApi::Base < RestApi::Base
  self.site = Console.config.community_url
  self.proxy = nil
end
