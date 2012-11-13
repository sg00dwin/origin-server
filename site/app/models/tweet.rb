class Tweet < RestApi::Base
  include RestApi::Cacheable
  allow_anonymous
  singleton

  self.site = 'http://api.twitter.com'
  self.prefix = '/1/statuses/'

  schema do
    string :id, :text
    date :created_at
  end

  class Entities < RestApi::Base
    class Hashtag < RestApi::Base
      def to_s
        "##{text}"
      end
      def url
        "https://twitter.com/search?q=#{CGI.escape to_s}"
      end
    end
    class Url < RestApi::Base
      schema do
        string :display_url, :expanded_url, :url
      end
      def to_s
        display_url.presence || url
      end
      def url
        expanded_url.presence || url
      end
    end
    class UserMention < RestApi::Base
      def to_s
        "@#{screen_name}"
      end
      def url
        "https://twitter.com/#{CGI.escape screen_name}"
      end
    end
  end

  class User < RestApi::Base
  end
  has_one :user, :class_name => 'tweet/user'
  has_one :retweeted_status, :class_name => 'tweet'

  def all_entities
    (entities.hashtags + entities.user_mentions + entities.urls).flatten rescue []
  end

  def text_with_entities
    s, last = [], 0
    all_entities.sort{ |a, b| a.indices[0] <=> b.indices[1] }.each do |e|
      s << text[last,e.indices[0]-last]
      s << e
      last = e.indices[1]
    end
    s << text[last..-1]
    s
  end

  cache_method :find_every, :expires_in => 30.minutes

  class << self
    def openshift_tweets
      all(
        :from => "#{prefix}user_timeline/openshift.json",
        :params => {
          :count => 10,
          :include_entities => true,
        }
      )
    end
    def openshift_retweets
      all(
        :from => "#{prefix}retweeted_by_user.json",
        :params => {
          :screen_name => :openshift,
          :count => 10,
          :include_entities => true,
        }
      )
    end
  end
end
