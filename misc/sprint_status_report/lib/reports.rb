require 'sprint'

module SprintReport
  attr_accessor :title, :headings, :function, :columns, :data, :day, :sort_key, :link, :friendly, :override
  attr_accessor :sprint
  def initialize(opts)
    opts.each do |k,v|
      send("#{k}=",v)
    end

    @columns = headings.map{|x| Column.new(x)}
    @data = []
  end

  def data
    if @data.empty? && sprint && function
      @data = sprint.send(function)
    end
    if sort_key
      @data.sort_by!{|x| x.is_a?(Hash) ? x[sort_key] : x.send(sort_key)}
    end
    @data
  end

  def offenders
    data.map{|x| x.owner}.uniq
  end

  def rows(user = nil)
    _data = data
    if user
      _data = data.select{|x| x.owner == user}
    end
    _data.map do |row|
      # Get data for each column
      columns.map do |col|
        col.process(row)
      end
    end
  end

  def print_title
    "%s %s" % [title, (!sprint.nil? && first_day?) ? "(to be completed by end of day today)" : '']
  end

  def required?
    if day.nil?
      true
    else
      ($date || Date.today) >= due_date
    end
  end

  def first_day?
    if day.nil?
      false
    else
      ($date || Date.today) == due_date
    end
  end

  def due_date
    sprint.send(:date_for, (override || function), day)
  end

  class Column
    attr_accessor :header, :attr, :fmt
    def initialize(opts)
      opts.each do |k,v|
        send("#{k}=",v)
      end
    end

    def process(row)
      value = row.is_a?(Hash) ?
        row[attr.to_sym] : row.send(attr)
      format(value)
    end

    # If no attr is specified, just use the heading name
    def attr
      @attr || header.downcase
    end

    # Format a string if needed (like for URLs)
    def format(value)
      value ||= '<none>'
      fmt ? (fmt % [value]) : value
    end
  end
end

class UserStoryReport
  include SprintReport
  def initialize(opts)
    _opts = {
      :headings => [
        { :header => 'ID', :attr => 'formatted_i_d' },
        { :header => 'Owner'},
        { :header => 'Name' },
      ],
      #:link => { :attr => 'object_i_d', :fmt => 'https://rally1.rallydev.com/#/detail/userstory/%s' },
      :sort_key => :owner
    }
    super(_opts.merge(opts))
  end
end

class StatsReport
  include SprintReport

  def initialize
    super({
      :title => "Sprint Stats",
      :function => :stats,
      :headings => [
        {:header => "Count"},
        {:header => "Name"},
      ],
      :sort_key => :date
    })
  end
end

class DeadlinesReport
  include SprintReport

  def initialize
    super({
      :title => "Upcoming Deadlines",
      :function => :upcoming,
      :headings => [
        {:header => "Date"},
        {:header => "Title"}
      ],
      :sort_key => :date
    })
  end
end

class EnvironmentsReport
  include SprintReport

  def initialize
    super({
      :title => "Environment Pushes",
      :function => :upcoming,
      :headings => [
        {:header => "Date"},
        {:header => "Title"}
      ],
      :sort_key => :date
    })
  end
end
