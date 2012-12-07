require 'uri'
require 'net/https'
require 'socket'
require 'models'
require 'logger'

def http_req(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host,uri.port)
  http.open_timeout = 10

  if uri.kind_of? URI::HTTPS
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  response = nil
  begin
    response = http.get(uri.path)
  rescue Errno::ECONNREFUSED, Timeout::Error => e
    response = "Server not running"
  rescue Errno::EHOSTUNREACH
    response = "Host unreachable"
  end

  if block_given?
    yield response
  else
    return response
  end
end

def get_hostname
  Socket.gethostname
end

def _log(string)
  logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  logger.debug("STATUS_APP: #{string}")
end

def delete_all
  [Issue,Update].each do |x|
    x.delete_all
  end
end

def dump_json
  { :issues => Issue.all, :updates => Update.all }.to_json
end

def time_ago_in_words(from_time, include_seconds = false)
  distance_of_time_in_words(from_time, Time.now, include_seconds)
end

def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false, options = {})
  from_time = from_time.to_time if from_time.respond_to?(:to_time)
  to_time = to_time.to_time if to_time.respond_to?(:to_time)
  distance_in_minutes = (((to_time - from_time).abs)/60).round
  distance_in_seconds = ((to_time - from_time).abs).round

  case distance_in_minutes
    when 0..1
      return distance_in_minutes == 0 ?
             "less than 1 minute" :
             pluralize(distance_in_minutes, 'minute') unless include_seconds

      case distance_in_seconds
        when 0..4   then "less than 5 seconds"
        when 5..9   then "less than 10 seconds"
        when 10..19 then "less than 20 seconds"
        when 20..39 then "half a minute"
        when 40..59 then "less than a minute"
        else             "1 minute"
      end

    when 2..44           then "#{distance_in_minutes} minutes"
    when 45..89          then "about 1 hour"
    when 90..1439        then "about " + (distance_in_minutes.to_f / 60.0).round.to_s + " hours"
    when 1440..2529      then "1 day"
    when 2530..43199     then (distance_in_minutes.to_f / 1440.0).round.to_s + " days"
    when 43200..86399    then "about 1 month"
    when 86400..525599   then "about " + (distance_in_minutes.to_f / 43200.0).round.to_s + " months"
    else
      distance_in_years           = distance_in_minutes / 525600
      minute_offset_for_leap_year = (distance_in_years / 4) * 1440
      remainder                   = ((distance_in_minutes - minute_offset_for_leap_year) % 525600)
      if remainder < 131400
        "about " + pluralize(distance_in_years, 'year')
      elsif remainder < 394200
        "over " + pluralize(distance_in_years, 'year')
      else
        "almost " + pluralize(distance_in_years, 'year')
      end
  end
end
