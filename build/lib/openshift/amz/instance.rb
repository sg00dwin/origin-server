require 'aws'

module OpenShift
  module AWS
    class Instance
      attr_accessor :conn, :amz_id, :name, :dns

      def log
        @@log
      end

      def initialize(conn, name)
        @conn, @name = conn, name

        log.info "Creating new instance..."

        # Launch a new instance
        @amz_id = @conn.launch_instances(AMI, OPTIONS)[0][:aws_instance_id]

        # Small sleep to avoid exceptions in AMZ call
        sleep 2

        # Tag the instance
        @conn.create_tag(@amz_id, 'Name', @name)

        # Block until the instance is accessible
        block_until_available
      end

      def terminate
        log.info "Terminating instance (#{@amz_id})..."
        @conn.terminate_instances([@amz_id])
      end

      def reboot
        log.info "Rebooting instance (#{@amz_id})..."
        @conn.reboot_instances([@amz_id])

        # Allow time for the instance to actually shutdown
        sleep 10

        # Block until the instance is SSH available
        block_until_available
      end

      def ssh(cmd, timeout=60)
        log.debug "(ssh: server = #{@dns} / timeout = #{timeout} / cmd = #{cmd})"
        output = ""
        begin
          ssh_cmd = "#{SSH} root@#{@dns} '#{cmd} 2>&1'"
          Timeout::timeout(timeout) { output = `#{ssh_cmd}`.chomp }
        rescue Timeout::Error
          log.error "SSH command timed out"
        end
        log.debug "----------------------------\n#{output}\n----------------------------"
        return output
      end

      def scp(from, to, timeout=60)
        log.debug "(scp: timeout = #{timeout}) / from = '#{from}' to = '#{to}'"
        output = ""
        begin
          scp_cmd = "#{SCP} -r #{from} root@#{@dns}:#{to}"
          Timeout::timeout(timeout) { output = `#{scp_cmd}`.chomp }
        rescue Timeout::Error
          log.error "SCP command '#{scp_cmd}' timed out"
        end
        log.debug "----------------------------\n#{output}\n------------------------------"
        return output
      end

      def retry_block(retry_msg, max_retries = 15)
        (0..max_retries).each do
          break if yield
          log.info retry_msg + "... retrying"
          sleep 5
        end
       
        unless yield
          raise "Operation Timed Out"
        end
      end

      def block_until_available
        log.info "Waiting for instance to be available..."

        (0..15).each do
          break if is_running?
          log.info "Instance isn't running yet... retrying"
          sleep 5
        end

        unless is_running?
          terminate
          raise "Timed out before instance was 'running'"
        end

        # Establish the DNS name
        @dns = get_value(:dns_name)

        (0..15).each do
          break if can_ssh?
          log.info "SSH access failed... retrying"
          sleep 5
        end

        unless can_ssh?
          terminate 
          raise "SSH availability timed out"
        end

        log.info "Instance (#{@amz_id} / #{@dns}) is accessible"
      end

      def get_value(key)
        @conn.describe_instances([@amz_id])[0][key]
      end

      def is_running?
        get_value(:aws_state) == "running"
      end

      def can_ssh?
        ssh('echo Success', 10).split[-1] == "Success"
      end

      def is_valid?
        output = ssh('/usr/bin/rhc-accept-node')
        log.info "Node Acceptance Output = #{output}"
        output == "PASS"
      end
    end
  end
end
