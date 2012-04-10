require 'benchmark'
require 'singleton'

module StatsHelper
  class StatMeasures
    attr_accessor :type, :name, :gearcnt, :cnt, :total, :mean, :variance,
                  :deltaMsquare, :min, :max;

    def initialize(type, name, ngears)
      @type = type
      @name = name
      @gearcnt = ngears
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
      return "#{@type},#{@gearcnt},#{@mean},#{@min},#{@max},#{stddev},#{@cnt},#{@total}\n"
    end

    def headings
      h  = "App Type    Gears  Avg secs  (    Min,    Max, StdDev, Count,        Sum)\n"
      h += "----------  -----  --------  --------------------------------------------\n"
      return h
    end

    def metrics
      ngears = "%5.5s" % @gearcnt.to_s
      avg = "%8.8s" % ("%4.2f" % @mean).to_s
      zmin = "%7.7s" % ("%4.2f" % @min).to_s
      zmax = "%7.7s" % ("%4.2f" % @max).to_s
      stddev = "%7.7s" % ("%4.2f" % Math.sqrt(@variance)).to_s
      cnt = "%6.6s" % @cnt.to_s
      tot = "%11.11s" % ("%8.2f" % @total).to_s
      misc = "#{zmin},#{zmax},#{stddev},#{cnt},#{tot}"
      return ("%10.10s" % @type) + "  #{ngears}  #{avg}  (#{misc})\n"
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
