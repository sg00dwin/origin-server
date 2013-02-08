require 'uri'
require 'net/http'
require 'fileutils'

class TwitterController < ApplicationController
  layout false

  def latest_tweets
    @tweets =
      begin
        Tweet.cached.openshift_tweets.first(4)
      rescue Exception => e
        logger.error "Exception fetching tweets: #{e}\n#{e.backtrace.join("\n  ")}"
        []
      end
    fresh_when :etag => @tweets.first
    expires_in 1.minutes, :public => true
  end

  def latest_retweets
    @retweets =
      begin
        Tweet.cached.openshift_retweets.first(4)
      rescue Exception => e
        logger.error "Exception fetching retweets: #{e}\n#{e.backtrace.join("\n  ")}"
        []
      end
    fresh_when :etag => @retweets.first
    expires_in 1.minutes, :public => true
  end
end
