require 'fileutils'
require 'zlib'

module ActionController
  class Base

    before_filter :profiler_start
    after_filter  :profiler_stop

    @@profiler_dir = "/tmp/broker-profiler"


    def profiler_start
      begin
        cfg=Rails.configuration.profiler
        if RubyProf.running?
          Rails.logger.debug("ApplicationController::profiler_start: Discarding old RubyProf run.")
          badresult=RubyProf.stop
        end
          
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

        @profiler_start_time = Time.now
        RubyProf.start

      rescue NoMethodError
      end
    end


    def profiler_stop
      begin
        cfg=Rails.configuration.profiler

        if RubyProf.running?
          Rails.logger.debug("ApplicationController::profiler_stop: RubyProf stopping.")
          result = RubyProf.stop
          duration = Time.now - @profiler_start_time
          RubyProf::exclude_threads = nil

          if cfg[:squash_threads]
            result.threads.delete_if { |key, value| key != Thread.current.object_id }
          end

          if cfg[:squash_runtime]
            result.eliminate_methods!([/^(Array|Hash|Kernel|Symbol|String|Exception|Fixnum|Class|NilClass|Proc|Range)\#/])
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

          timestamp=@profiler_start_time.strftime('%Y-%m-%d-%H-%M-%S')
          reportfile=File.join(@@profiler_dir, "profiler-#{cfg[:measure]}-#{cfg[:type]}-#{timestamp}.#{printext}.gz")
          infofile=File.join(@@profiler_dir, "profiler-info-#{timestamp}.json.gz")

          Rails.logger.debug("ApplicationController::profiler_stop: writing #{cfg[:type]} report in #{reportfile}, info in #{infofile}")

          infohdrs = {}
          request.headers.each do |k, v|
            next if k[0..4] == 'rack.'
            next if k[0..6] == 'action_'
            next if k == '_'
            v = '[hidden]' if k == 'PASSENGER_CONNECT_PASSWORD'
            v = '[hidden]' if k == 'HTTP_AUTHORIZATION'
            infohdrs[k.to_s]=v.to_s
          end

          infoparams = {}
          params.each do |k, v|
            v = '[hidden]' if k == 'password'
            if k == 'json_data'
              begin
                infoparams[k.to_s]=JSON.parse(v)
              rescue
              end
            else
              infoparams[k.to_s]=v.to_s
            end
          end

          infoout = {
            :TIMESTAMP   => @profiler_start_time.to_s,
            :TIMESTAMP_F => @profiler_start_time.to_f,
            :DURATION    => duration.to_f,
            :ENDSTAMP    => (@profiler_start_time + duration).to_s,
            :ENDSTAMP_F  => (@profiler_start_time + duration).to_f,
            :HOST        => request.host.to_s,
            :DOMAIN      => request.domain.to_s,
            :FORMAT      => request.format.to_s,
            :METHOD      => request.method.to_s,
            :HEADERS     => infohdrs,
            :PARAMS      => infoparams,
            :PORT        => request.port.to_s,
            :PROTOCOL    => request.protocol.to_s,
            :QUERY_STR   => request.query_string.to_s,
            :REMOTE_IP   => request.remote_ip.to_s,
            :URL         => request.url.to_s,
            :STATUS      => response.status,
            :CONTENT_TYPE => response.content_type
          }

          FileUtils.mkdir_p(@@profiler_dir)

          Zlib::GzipWriter.open(infofile) do |f|
            f.puts(JSON.pretty_generate(infoout))
          end

          p=printer.new(result)
          Zlib::GzipWriter.open(reportfile) do |f|
            p.print(f, cfg)
          end

        end
      end
    rescue NoMethodError
    end

  end
end

class ApplicationController < ActionController::Base
  before_filter :store_user_agent
  protect_from_forgery
  
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
end
