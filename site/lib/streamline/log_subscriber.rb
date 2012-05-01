module Streamline
  class LogSubscriber < ActiveSupport::LogSubscriber
    def self.runtime=(value)
      Thread.current["streamline_call_runtime"] = value
    end
    def self.runtime
      Thread.current["streamline_call_runtime"] ||= 0
    end
    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end

    def request(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      name = '%s (%.1fms)' % ['Streamline call', event.duration]

      call = "#{color(event.payload.delete(:method), BOLD, true)} #{event.payload.delete(:uri)}"

      query = event.payload.map{ |k,v| "#{k}: #{color(v, BOLD, true)}" }.join(', ')

      debug "  #{color(name, YELLOW, true)} #{call} [ #{query} ]"
    end
  end
end

