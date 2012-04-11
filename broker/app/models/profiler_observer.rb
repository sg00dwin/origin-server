class ProfilerObserver < ActiveModel::Observer
  observe Application


  def before_application_create(data)
    profile_start("application_create", data[:application])
  end

  def after_application_create(data)
    profile_stop("application_create", data[:application])
  end


  def profile_start(call_name, tag=nil)
    if Rails.configuration.profile_enable
      if not RubyProf.running?
        RubyProf.start
      end
    end
  end

  def profile_stop(call_name, tag=nil)
    if Rails.configuration.profile_enable
      if RubyProf.running?
        result = RubyProf.stop
        case Rails.configuration.profile_type
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

        printer.new(result)

        timestamp=Time.now.strftime('%Y-%m-%d-%H-%M-%S')
        outfile=File.join(Dir.tmpdir, '#{call_name}-#{tag}-#{Rails.configuration.profile_type}-#{timestamp}.#{printext}')
        File.open(outfile, 'wb') do |file|
          printer.print(outfile, :min_percent=>Rails.configuration.profile_min_percent)
        end

      end
    end
  end

end
