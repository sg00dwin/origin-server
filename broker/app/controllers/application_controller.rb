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
          Rails.logger.debug("ApplicationController::profiler_start: Squashing threads: " +
                             (et.map { |t| t.object_id }).join(', '))
          RubyProf::exclude_threads = et
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
        outfile=File.join(Dir.tmpdir, "#{timestamp}-#{cfg[:type]}.#{printext}")

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
