module AriaHelper

  def aria_direct_post_url(opts=nil)
    if opts
      uri = URI.parse(Rails.application.config.aria_direct_post_uri)
      uri.query = CGI.parse(uri.query || '').merge(opts).to_query
      uri.to_s
    else
      Rails.application.config.aria_direct_post_uri
    end
  end

end
