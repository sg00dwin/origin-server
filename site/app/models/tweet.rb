class Tweet < RestApi::Base
  include RestApi::Cacheable
  include RestApi::Oauth
  allow_anonymous
  singleton

  self.site = 'https://api.twitter.com'
  self.prefix = '/1.1/statuses/'

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

  cache_method :find_every, :expires_in => 10.minutes
  cache_method :openshift_tweets, :expires_in => 10.minutes
  cache_method :openshift_retweets, :expires_in => 10.minutes

  class << self
    def oauth_consumer_key
      ENV['TWITTER_OAUTH_CONSUMER_KEY'] || ''
    end

    def oauth_consumer_secret
      ENV['TWITTER_OAUTH_CONSUMER_SECRET'] || ''
    end

    def oauth_token
      ENV['TWITTER_OAUTH_TOKEN'] || ''
    end

    def oauth_token_secret
      ENV['TWITTER_OAUTH_TOKEN_SECRET'] || ''
    end

    # twitter api 1.1 does not provide individual filters for retweets, so the strategy (recommended
    # by twitter) is to fetch a good amount of tweets from the user timeline and then filter
    def openshift_timeline
      params = {
        'screen_name' => 'openshift',
        'count' => 50,
        'trim_user' => false,
        'exclude_replies' => true,
        'contributor_details' => true,
        'include_rts' => true,
      }
      url = "#{prefix}user_timeline.json?#{params.map{|k,v| k + '=' + v.to_s}.join('&')}"
      oauth "#{site}#{url}", oauth_consumer_key, oauth_consumer_secret, oauth_token, oauth_token_secret
      all(:from => url)
    end

    def openshift_tweets
      openshift_timeline.select {|tweet| ! tweet.respond_to? :retweeted_status}
    end

    def openshift_retweets
      openshift_timeline.select {|tweet| tweet.respond_to? :retweeted_status}
    end
  end
end
