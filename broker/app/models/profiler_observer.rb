class ProfilerObserver < ActiveModel::Observer
  observe Application


  def before_application_create(data)
    profile_start("application_create", data[:application].name)
  end

  def after_application_create(data)
    profile_stop("application_create", data[:application].name)
  end


  def profile_start(call_name, call_tag="")
    begin
      Rails.logger.debug("ProfilerObserver::profile_start: #{call_name} #{call_tag}")
      cfg=Rails.configuration.profile
      Rails.logger.debug("ProfilerObserver::profile_start: Profile is configured")
      if not RubyProf.running?
        Rails.logger.debug("ProfilerObserver::profile_start: RubyProf was stopped. Running.")
        RubyProf.start
      end
    rescue NoMethodError
    end
  end


  def profile_stop(call_name, call_tag="")
    begin
      Rails.logger.debug("ProfilerObserver::profile_stop: #{call_name} #{call_tag}")
      cfg=Rails.configuration.profile

      Rails.logger.debug("ProfilerObserver::profile_stop: Profile is configured")
      if RubyProf.running?
        Rails.logger.debug("ProfilerObserver::profile_stop: RubyProf was running.  Stopping.")
        result = RubyProf.stop

        timestamp=Time.now.strftime('%Y-%m-%d-%H-%M-%S')
        outfile=File.join(Dir.tmpdir, '#{call_name}-#{call_tag}-#{cfg[:type]}-#{timestamp}.#{printext}')

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

        Rails.logger.debug("ProfilerObserver::profile_stop: writing #{cfg[:type]} report in #{outfile}")
        printer.new(result)
        File.open(outfile, 'wb') do |file|
          printer.print(outfile, :min_percent=>cfg[:min_percent])
        end

      end
    end
  rescue NoMethodError
  end

end
