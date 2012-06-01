class TestResult
  attr_accessor :name, :result, :time
  def initialize(name,time,result = nil)
    @name = name
    @result = result
    @time = time
  end

  def to_s(len)
    str =  "\t%#{len}s: %s" % [name.to_s.upcase,fmt_time(time)]
    str += " (#{result})" if result
    str
  end

  private
  def fmt_time(total)
    m = (total/60).floor
    s = (total - (m*60)).floor
    f = ("%.3f" % [total-(m*60)- s]).gsub(/^../,'')
    ("%02d:%02d.%s" % [m,s,f])
  end
end

class TestResultSet
  include MyLogger
  attr_accessor :results, :tests, :max_len

  def initialize(tests)
    @tests = tests
    @max_len = [tests,:total].flatten.map{|x| x.to_s.length}.max
    @results = []
  end

  def <<(result)
    results << result
    puts result.to_s(max_len)
  end

  def total
    TestResult.new("TOTAL",results.map{|r| r.time}.inject{|sum,x| sum + x})
  end

  def finish
    row = total.to_s(max_len)
    puts "-"*row.length
    puts row

    errors = results.map{|r| r.result.msg }.compact

    def center(str,max)
      len = str.length + 2
      left = (max - len ) / 2
      right = max - left - len
      "*%s%s%s*" % [" " * left, str, " " * right]
    end

    unless errors.empty?
      padding = 2
      max_err_len = errors.map{|x| x.length}.max + (padding * 2 + 2)
      puts
      puts "*"*(max_err_len)
      errors.each do |e|
        puts center(e,max_err_len)
      end
      puts "*"*(max_err_len)
    end
  end
end
