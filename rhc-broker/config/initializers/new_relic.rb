begin
  if File.exists?('/etc/openshift/newrelic.yml') && ENV["ENABLE_NR_MONITORING"]
    ENV["NRCONFIG"] = "/etc/openshift/newrelic.yml"
    require 'newrelic_rpm'
    require 'newrelic_moped'
    new_relic_conf = YAML.load_file(ENV["NRCONFIG"])
    args = {}
    args[:app_name] = 'broker-' + new_relic_conf["common"]["app_name"]
    args[:log_file_name] = "broker-" + new_relic_conf["common"]["log_file_name"]
    NewRelic::Agent.manual_start(args)

    OpenShift::ApplicationContainerProxy.class_eval do
      include NewRelic::Agent::MethodTracer

      self.singleton_methods(false).each do |m|
        add_method_tracer m if m.to_s.match(/^provider=$|^instance$|.*_impl\??$/).nil?
      end

      @proxy_provider.class_eval do
        include NewRelic::Agent::MethodTracer

        self.public_instance_methods(false).each do |m|
          add_method_tracer m if m.to_s.match(/^id$|\=$|^build_base_/).nil?
        end
      end

    end
  end
rescue Exception => e
  Rails.logger.error "Unable to start New Relic: #{e.message}"
  Rails.logger.error e.backtrace.inspect  
end