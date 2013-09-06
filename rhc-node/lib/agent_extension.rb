module Openshift
  module AgentExtension
    # will be run when the openshift mcollective agent's active_when block is run
    module ClassMethods
      def agent_startup
        start_monitoring if respond_to? :start_monitoring
      end
    end

    if File.exists?('/etc/openshift/newrelic.yml')
      ENV["NRCONFIG"] = "/etc/openshift/newrelic.yml"
      require 'newrelic_rpm'
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, NewRelic::Agent::Instrumentation::ControllerInstrumentation)
        base.send(:define_method, :newrelic_request) { |*args| nil }
        base.send(:add_transaction_tracer, :execute_action , :name => '#{[args[0],args[1]["--cart-name"]].compact().join("_")}')
      end

      module ClassMethods
        def start_monitoring
          new_relic_conf = YAML.load_file(ENV["NRCONFIG"])
          args = {}
          args[:app_name] = 'node-' + new_relic_conf["common"]["app_name"]
          args[:log_file_name] = "node-" + new_relic_conf["common"]["log_file_name"]
          NewRelic::Agent.manual_start(args)
        rescue Exception => e
          Log.instance.error "Unable to start New Relic: #{e.message}"
          Log.instance.error e.backtrace.inspect  
        end
      end
    end
  end
end