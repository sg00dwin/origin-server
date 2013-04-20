Rails.application.config.tap do |config|
  # Twitter API information
  config.twitter_api_site = 'https://api.twitter.com'
  config.twitter_api_prefix = '/1.1/statuses/'
  config.twitter_oauth_consumer_key = Console.config.env(:TWITTER_OAUTH_CONSUMER_KEY, 'kRJ1Hjo3uNd2M8zKCCF0bw')
  config.twitter_oauth_consumer_secret = Console.config.env(:TWITTER_OAUTH_CONSUMER_SECRET, 'psNvYg3IOAhWtngxBobajkYWKlus53xkNBQxWz3MU')
  config.twitter_oauth_token = Console.config.env(:TWITTER_OAUTH_TOKEN, '17620820-rm2UBzOWYrETRh2Ut4rjkGISqmkfdlVKSYcmmAOGt')
  config.twitter_oauth_token_secret = Console.config.env(:TWITTER_OAUTH_TOKEN_SECRET, 'aFfOPRBJBckWarMxlWYg3MljK6EgoaKUW9CjFSsaG8')
end