module Streamline
  module Railties
    module ControllerRuntime
      extend ActiveSupport::Concern

      protected

      attr_internal :st_runtime

      def process_action(action, *args)
        Streamline::LogSubscriber.reset_runtime
        super
      end

      def cleanup_view_runtime
        rt_before_render = Streamline::LogSubscriber.reset_runtime
        runtime = super
        rt_after_render = Streamline::LogSubscriber.reset_runtime
        self.st_runtime = rt_before_render + rt_after_render
        runtime - rt_after_render
      end

      def append_info_to_payload(payload)
        super
        payload[:st_runtime] = st_runtime
      end

      module ClassMethods
        def log_process_action(payload)
          messages, streamline_runtime = super, payload[:st_runtime]
          messages << ("Streamline: %.1fms" % streamline_runtime.to_f) if !streamline_runtime.nil? && streamline_runtime > 0
          messages
        end
      end
    end
  end
end
