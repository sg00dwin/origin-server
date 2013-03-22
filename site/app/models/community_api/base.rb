class CommunityApi::Base < RestApi::Base
  self.site = Console.config.community_url || ('https://localhost:8118/' if Rails.env.development?)
  self.proxy = nil
end
