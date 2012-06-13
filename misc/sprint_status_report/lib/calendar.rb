require 'ri_cal'
require 'net/http'
require 'net/https'
require 'uri'

class SprintCalendar

  def initialize(path)
    @calendar = get_ical(path).first
    @dates = {}
  end

  def get_ical(path)
    uri = URI.parse(path)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    request = Net::HTTP::Get.new(uri.request_uri)

    http.request(request) do |req|
      case req
      when Net::HTTPSuccess
        return RiCal.parse_string(req.body)
      end
    end
  end

  def get_date(summary,args = nil, item = :last)
    @dates[summary] ||=
      @calendar.events.select{|x| x.summary =~ /^#{summary}/}
      .map{|x| x.occurrences(args)}.flatten
      .send(item)
  end

  def start_date
    get_date("Start Sprint",{:before => (Date.today + 1)})
  end

  def sprint_name
    start_date.summary.scan(/Sprint \d+/).first
  end

  def end_date
    get_date("End Sprint",{:after => start_date.dtstart, :count => 1})
  end

  def dcut_date
    get_date("dcut build",{:overlapping => [start_date.dtstart,end_date.dtstart] },:first)
  end

  def sprint_args
    args = {
      :name   => sprint_name,
      :day    => (Date.today - start_date.dtstart.to_date).to_i + 1,
      :number => sprint_name.scan(/\d+/).first
    }
    [:start,:end,:dcut].each do |x|
      args[x] = send("#{x}_date").dtstart.to_date
    end
    args
  end
end
