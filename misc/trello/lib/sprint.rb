require 'trello_helper'
require 'queries'
require 'core_ext/date'

class Sprint
  # Rally Config
  attr_accessor :username, :password
  # Calendar related attributes
  attr_accessor :start, :finish
  # Trello related attributes
  attr_accessor :trello
  # UserStory related attributes
  attr_accessor :stories, :processed, :results

  attr_accessor :debug

  def initialize(opts)
    opts.each do |k,v|
      send("#{k}=",v)
    end
    get_stories
  end

  def day
    $date ||= Date.today # Allow overriding for testing
    ($date - start + 1).to_i
  end

  def show_days(report)
    puts "%s - Starts on %s" % [report.title,report.day]
    puts
    (start..send(:end)).each do |x|
      $date = x
      req = case
            when report.first_day?
              "Start"
            when report.required?
              "  |  "
            else
              ''
            end
      puts "%s (%2d) - %s" % [x,day,req]
    end
    $date ||= Date.today
  end

  def finish
    return @finish if @finish
    broker_board = trello.board(trello.broker_id)
    broker_board.lists.each do |list|
      if list.name == 'In Progress'
        sprint_card = list.cards.sort_by { |card| card.pos }.first
        @finish = sprint_card.due.to_date
        return @finish
      end
    end
  end
  
  def start
    finish.previous(:monday).previous(:monday).previous(:monday)
  end

  def prod
    finish.next(:monday)
  end

  def stg
    finish
  end

  def int
    start.next(:friday)
  end

  def title(short = false)
    str = "Report for Current Sprint: Day %d" % [day]
    str << " (%s - %s)" % [start, self.finish] unless short
    str
  end

  def get_stories
    # Reset processed status
    @processed = {}
    @results = {}

    @stories = []
    trello.boards.each do |board_id, board|
      lists = board.lists.target
      lists.each do |list|
        if list.name == 'In Progress' || list.name == 'Complete' || list.name == 'Accepted'
          cards = list.cards.target
          cards = cards.delete_if {|card| card.name =~ /^Sprint \d+/ && !card.due.nil?}
          @stories += cards
        end
      end
    end
    @stories
  end

  def find(name, match = true)
    query = queries[name]
    where = stories
    if parent = query[:parent]
      where = send(parent)
    end

    unless !debug && processed[name]
      retval = where.partition do |x|
        query[:function].call(x)
      end

      results[name] = {
        true  => retval[0],
        false => retval[1]
      }
    end

    results[name][match]
  ensure
    processed[name] = true
  end
  
  private
  def method_missing(method,*args,&block)
    begin
      case method.to_s
      when *(queries.keys.map(&:to_s))
        find(method,*args)
      when /^not_/
        meth = method.to_s.scan(/not_(.*)/).flatten.first.to_sym
        send(meth,false)
      else
        super
      end
    rescue ArgumentError
      super
    end
  end

end
