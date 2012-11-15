require 'uri'
require 'net/http'
require 'fileutils'

class TwitterController < ApplicationController

  def latest_tweet
    get_and_render('user_timeline/openshift.json?count=10&include_entities=true', 'openshift_twitter_latest_tweet.json') and return
  end
  
  def latest_retweets
    get_and_render('retweeted_by_user.json?screen_name=openshift&count=4&include_entities=true', 'openshift_twitter_latest_retweets.json') and return
  end
  
  def get_and_render(url_path, file_name)
    begin
      body = get(url_path, file_name)
      render :json => body and return
    rescue Exception
      render :json => nil, :status => :internal_server_error
    end
  end
  
  def get(url_path, file_name)
    file_path = "#{Rails.root}/tmp/#{file_name}"
    update_file_path = file_path + '.' + Thread.current.object_id.to_s
    file = nil
    json = nil
    begin
      if File.exists?(file_path)
        last_mod = File.mtime(file_path)
        if (Time.now - last_mod) > 600 # 10 mins
          FileUtils.touch(file_path) # update current file to keep most people out
          Rails.logger.debug("Updating twitter cache using: #{update_file_path}")
          file = File.new(update_file_path, "w")
        else
          Rails.logger.debug("Twitter cache hit using: #{file_path}")
          file = File.open(file_path, "r")
          json = file.read
        end
      else
        Rails.logger.debug("Initial twitter hit using: #{file_path}")
        file = File.new(update_file_path, "w")
      end
      
      unless json
        Rails.logger.debug("Fetching from twitter: #{url_path}")
        json = twitter_get(url_path)
        file.print json
        FileUtils.mv(update_file_path, file_path, :force => true)
      end
    rescue Exception => e
      Rails.logger.debug("Rescued exception: #{e.message}")
      Rails.logger.debug(e.backtrace)
      file.close if file
      file = nil
      if File.exists?(update_file_path)
        File.delete(update_file_path)
      end
      raise
    ensure
      file.close if file
    end
    json
  end

  def twitter_get(url_path)
    url = URI.parse('http://api.twitter.com/1/statuses/' + url_path)
    req = Net::HTTP::Get.new(url.path + '?' + url.query)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    case res
    when Net::HTTPSuccess
      raise Exception if !res.body || res.body.empty?
    else
      raise Exception
    end
    res.body
  end
  
end
