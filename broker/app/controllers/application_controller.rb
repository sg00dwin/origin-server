class ApplicationController < ActionController::Base
  before_filter :profiler_start, :store_user_agent
  after_filter  :profiler_stop
  
  @@outage_notification_file = '/etc/stickshift/express_outage_notification.txt'  
  
  def store_user_agent
    user_agent = request.headers['User-Agent']
    Rails.logger.debug "User-Agent = '#{user_agent}'"
    Thread.current[:user_agent] = user_agent
  end
  
  def notifications
    details = nil
    if File.exists?(@@outage_notification_file)
      file = File.open(@@outage_notification_file, "r")
      begin
        details = file.read
      ensure
        file.close
      end
    end
    
    details
  end


  def profiler_start
    begin
      cfg=Rails.configuration.profiler
      if not RubyProf.running?
        Rails.logger.debug("ApplicationController::profiler_start: RubyProf starting.")

        if cfg[:squash_threads]
          et=[]
          Thread.list.each do |th|
            et << th if th != Thread.current
          end
          RubyProf::exclude_threads = et
        end

        case cfg[:measure]
        when "proc"
          RubyProf.measure_mode = RubyProf::PROCESS_TIME
        when "wall"
          RubyProf.measure_mode = RubyProf::WALL_TIME
        when "cpu"
          RubyProf.measure_mode = RubyProf::CPU_TIME
        when "alloc"
          RubyProf.measure_mode = RubyProf::ALLOCATIONS
        when "mem"
          RubyProf.measure_mode = RubyProf::MEMORY
        when "gc_runs"
          RubyProf.measure_mode = RubyProf::GC_RUNS
        when "gc_time"
          RubyProf.measure_mode = RubyProf::GC_TIME
        else
          RubyProf.measure_mode = RubyProf::PROCESS_TIME
        end

        RubyProf.start

      end
    rescue NoMethodError
    end
  end


  def profiler_stop
    begin
      cfg=Rails.configuration.profiler

      if RubyProf.running?
        Rails.logger.debug("ApplicationController::profiler_stop: RubyProf stopping.")
        result = RubyProf.stop
        RubyProf::exclude_threads = nil

        if cfg[:squash_threads]
          result.threads.delete_if { |key, value| key != Thread.current.object_id }
        end

        if cfg[:squash_runtime]
          result.eliminate_methods!([/^(Array|Hash|Kernel|Symbol|String|Exception|Fixnum|Class|NilClass|Proc)\#/])
        end

        case cfg[:type]
        when "flat"
          printer=RubyProf::FlatPrinter
          printext="txt"
        when "graph"
          printer=RubyProf::GraphPrinter
          printext="txt"
        when "graph_html"
          printer=RubyProf::GraphHtmlPrinter
          printext="html"
        when "call_tree"
          printer=RubyProf::CallTreePrinter
          printext="txt"
        when "call_stack"
          printer=RubyProf::CallStackPrinter
          printext="html"
        else
          printer=RubyProf::FlatPrinter
          printext="txt"
        end

        timestamp=Time.now.strftime('%Y-%m-%d-%H-%M-%S')
        outfile=File.join(Dir.tmpdir, "profiler-#{cfg[:measure]}-#{cfg[:type]}-#{timestamp}.#{printext}")

        Rails.logger.debug("ApplicationController::profiler_stop: writing #{cfg[:type]} report in #{outfile}")
        p=printer.new(result)

        File.open(outfile, 'wb') do |f|
          p.print(f, cfg)
        end

      end
    end
  rescue NoMethodError
  end


end
