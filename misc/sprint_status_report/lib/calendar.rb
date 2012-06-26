require 'ri_cal'
require 'net/http'
require 'net/https'
require 'uri'

DEFAULT_DATES = {
  :start  => 21,
  :dcut   => 10,
  :end    => 8    # This is relative to dcut
}

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
    date = get_date("Start Sprint",{:before => (Date.today + 1)})
    if (Date.today - date.dtstart) > DEFAULT_DATES[:end]
      say("Warning: Old Sprint found, estimating dates")
      date.dtstart = date.dtstart + DEFAULT_DATES[:start] 
      @old = true
    end
    date
  end

  def sprint_name
    name = start_date.summary.scan(/Sprint \d+/).first
    if @old
      number = name.scan(/Sprint (\d+)/).first.first.to_i + 1
      name = "Sprint #{number}" 
    end
    name
  end

  def end_date
    if @old
      d = start_date
      d.dtstart = d.dtstart + DEFAULT_DATES[:end]
      d
    else
      get_date("End Sprint",{:after => start_date.dtstart, :count => 1})
    end
  end

  def dcut_date
    if @old
      d = start_date
      d.dtstart = d.dtstart + DEFAULT_DATES[:dcut]
      d
    else
      get_date("dcut build",{:overlapping => [start_date.dtstart,end_date.dtstart] },:first)
    end
  end

  def sprint_args
    args = {
      :name   => sprint_name,
      :number => sprint_name.scan(/\d+/).first
    }
    [:start,:dcut,:end].each do |x|
      args[x] = send("#{x}_date").dtstart.to_date
    end
    args
  end
end
