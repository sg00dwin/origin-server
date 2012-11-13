class ProductController < SiteController

  def index
    @posts = BlogPost.cached.frontpage.first(3) rescue []
    @tweets = Tweet.cached.openshift_tweets.first(4) rescue []
    @retweets = Tweet.cached.openshift_retweets.first(4) rescue []
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
