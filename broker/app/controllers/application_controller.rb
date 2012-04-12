class ApplicationController < ActionController::Base
  before_filter :profile_start, :store_user_agent
  after_filter  :profile_stop
  
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


  def profile_start
    begin
      Rails.logger.debug("ProfilerObserver::profile_start")
      cfg=Rails.configuration.profile
      Rails.logger.debug("ProfilerObserver::profile_start: Profile is configured")
      if not RubyProf.running?
        Rails.logger.debug("ProfilerObserver::profile_start: RubyProf was stopped. Running.")
        RubyProf.start
      end
    rescue NoMethodError
    end
  end


  def profile_stop
    begin
      Rails.logger.debug("ProfilerObserver::profile_stop")
      cfg=Rails.configuration.profile

      Rails.logger.debug("ProfilerObserver::profile_stop: Profile is configured")
      if RubyProf.running?
        Rails.logger.debug("ProfilerObserver::profile_stop: RubyProf was running.  Stopping.")
        result = RubyProf.stop

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

        Rails.logger.debug("ProfilerObserver::profile_stop: writing #{cfg[:type]} report in #{outfile}")
        p=printer.new(result)
        File.open(outfile, 'wb') do |f|
          p.print(f, :min_percent=>cfg[:min_percent])
        end

      end
    end
  rescue NoMethodError
  end


end
