class ProductController < SiteController

  def index
    @posts = BlogPost.cached.frontpage.first(3) rescue []
    begin
      @tweets = Tweet.cached.openshift_tweets.first(4)
    rescue Exception => e
      logger.error "Exception fetching tweets: #{e}\n#{e.backtrace.join("\n  ")}"
      @tweets = [] if ! @tweets
    end
    begin
      @retweets = Tweet.cached.openshift_retweets.first(4)
    rescue Exception => e
      logger.error "Exception fetching retweets: #{e}\n#{e.backtrace.join("\n  ")}"
      @retweets = [] if ! @retweets
    end
  end

  def not_found
  end

  def error
    render 'console/error'
  end

  def console_not_found
    render 'console/not_found', :layout => 'console'
  end

  def console_error
    render 'console/error', :layout => 'console'
  end
end
