module TweetHelper
  def tweet(status)
    status.text_with_entities.map do |i|
      next i if i.is_a? String
      if i.respond_to? :url
        link_to i.to_s, i.url
      else
        i
      end
    end.join.html_safe
  end
end
