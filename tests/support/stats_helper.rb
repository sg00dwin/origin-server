require 'benchmark'
require 'singleton'

module StatsHelper
  class StatMeasures
    attr_accessor :type, :name, :cnt, :total, :mean, :variance, :deltaMsquare,
                  :min, :max;

    def initialize(type, name)
      @type = type
      @name = name
      @cnt, @total, @mean, @variance, @deltaMsquare = 0, 0, 0.0, 0.0, 0.0
      @min, @max = 2**30 - 1, 0.0
    end

    def add(val)
      #Increment number of entries and compute delta from current mean.
      @cnt += 1
      delta = val - @mean

      # Add the value to the running totals.
      @total += val

      # Compute current mean by distributing the delta.
      @mean += (delta/@cnt)

      # Compute new delta (from the new mean we calculated above).
      newdelta = val - @mean

      # Add to the sum of squares of differences from current mean.
      @deltaMsquare += (delta * newdelta)

      # And finally compute the variance - we don't compute the standard
      # deviation in here every time but just do it once at the very end.
      # Standard deviation is just the square root of the variance anyway.
      @variance = (@deltaMsquare)/(@cnt - 1) if @cnt > 1 

      # Check if value's a min/max value.
      @max = val if val > @max
      @min = val if val < @min
    end

    def raw
      stddev = Math.sqrt(@variance)
      return "#{@type},#{@mean},#{@min},#{@max},#{stddev},#{@cnt},#{@total}\n"
    end

    def headings
      h  = "App Type      Avg secs\t Misc (Min, Max, StdDev, Count, Sum)     \n"
      h += "------------  --------\t ----------------------------------------\n"
      return h
    end

    def metrics
      avg = "%4.2f" % @mean
      zmin = "%4.2f" % @min
      zmax = "%4.2f" % @max
      stddev = "%3.2f" % Math.sqrt(@variance)
      cnt = "%6d" % @cnt
      tot = "%8.2f" % @total
      misc = "#{zmin}, #{zmax}, #{stddev}, #{cnt}, #{tot}"
      return "%12.12s" % @type + "  #{avg}\t (#{misc})\n"
    end

  end


  class StatsReport
    include Singleton
    @@raw  = ''
    @@data = ''
    @@headings = nil

    def clear
      @@raw  = ''
      @@data = ''
      @@headings = nil
    end

    def addstats(sm)
      @@raw  += sm.raw
      @@data += sm.metrics
      @@headings = sm.headings if !@@headings
    end

    def rawmetrics(prefix)
      @@raw.each_line.collect { |line| "#{prefix},#{line}" }
    end

    def report(name)
      $logger.info("#{name} statistical measures:")
      $logger.info(@@headings + @@data)

      puts "=" * 80
      puts "#{name} statistical measures:\n"
      puts "=" * 80

      puts @@headings
      puts @@data
    end
  end
    
end

World(StatsHelper)
