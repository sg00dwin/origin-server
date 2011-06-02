require 'aws'
require 'pp'

module OpenShift
  module AWS
    def terminate_flagged_instances(conn)
      # Terminate any instances stopped and tagged with 'terminate'
      instances = conn.describe_instances.collect do |i|
        if (i[:aws_state] == "stopped") and (i[:tags]["Name"] =~ TERMINATE_REGEX)
          i[:aws_instance_id]
        end
      end.compact

      log.info "Terminating #{instances.pretty_inspect}"
      conn.terminate_instances(instances) unless instances.empty?
    end

    def stop_untagged_instances(conn)
      # Stop all running instances without a tagged name
      instances = conn.describe_instances.collect do |i|
        if (i[:aws_state] == "running") and (i[:tags]["Name"] == nil)
          i[:aws_instance_id]
        end
      end.compact

      # Tag everything without a name as 'will-terminate'
      conn.describe_instances.each do |i|
        unless i[:tags]["Name"]
          conn.create_tag(i[:aws_instance_id], 'Name', "will-terminate")
        end
      end.compact

      log.info "Stopping untagged instances #{instances.pretty_inspect}"
      conn.stop_instances(instances) unless instances.empty?
    end
  end
end
