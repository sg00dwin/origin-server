require 'aws'

module OpenShift
  module AWS
    class Instance
      attr_accessor :conn, :amz_id, :amz_image_id, :name, :dns

      def log
        @@log
      end

      def self.find(conn, name)
        # Look up any tagged instances that aren't terminated
        conn.describe_instances.each do |i|
          if ((i[:tags]["Name"] == name) and
              (i[:aws_state] != "terminated"))
            puts "Found instance #{i[:aws_instance_id]}"
            instance = Instance.new(conn, name)
            instance.amz_id = i[:aws_instance_id]
            instance.amz_image_id = i[:aws_image_id]
            instance.block_until_available
            return instance
          end
        end
      end

      def self.create(conn, name, ami = AMI)
        log.info "Creating new instance..."

        instance = Instance.new(conn, name)

        # Launch a new instance
        amz_data = conn.launch_instances(ami, $amz_options)[0]
        instance.amz_id = amz_data[:aws_instance_id]
        instance.amz_image_id = amz_data[:aws_image_id]

        # Small sleep to avoid exceptions in AMZ call
        sleep 2

        # Tag the instance
        conn.create_tag(instance.amz_id, 'Name', instance.name)

        # Block until the instance is accessible
        instance.block_until_available

        return instance
      end

      def initialize(conn, name)
        @conn, @name = conn, name
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

      def ssh(cmd, timeout=60, return_exit_code=false)
        log.debug "(ssh: server = #{@dns} / timeout = #{timeout} / cmd = #{cmd})"
        output = ""
        exit_code = 1
        begin
          ssh_cmd = "#{SSH} root@#{@dns} '#{cmd} 2>&1'"
          Timeout::timeout(timeout) do
            output = `#{ssh_cmd}`.chomp
            exit_code = $?.exitstatus
          end
        rescue Timeout::Error
          log.error "SSH command timed out"
        end
        log.debug "----------------------------\n#{output}\n----------------------------"

        if return_exit_code
          return output, exit_code
        else
          return output
        end
      end

      def scp_from(remote, local, timeout=60)
        log.debug "(scp_from: timeout = #{timeout}) / local = '#{local}' remote = '#{remote}'"
        output = ""
        begin
          scp_cmd = "#{SCP} -r root@#{@dns}:#{remote} #{local}"
          Timeout::timeout(timeout) { output = `#{scp_cmd}`.chomp }
        rescue Timeout::Error
          log.error "SCP command '#{scp_cmd}' timed out"
        end
        log.debug "----------------------------\n#{output}\n------------------------------"
        return output
      end

      def scp_to(local, remote, timeout=60)
        log.debug "(scp_to: timeout = #{timeout}) / local = '#{local}' remote = '#{remote}'"
        output = ""
        begin
          scp_cmd = "#{SCP} -r #{local} root@#{@dns}:#{remote}"
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
        unless @is_running
          @is_running = get_value(:aws_state) == "running"
        end
        return @is_running
      end

      def can_ssh?
        unless @can_ssh
          @can_ssh = ssh('echo Success', 10).split[-1] == "Success"
        end
        return @can_ssh 
      end

      def is_valid?
        output = ssh('/usr/bin/rhc-accept-node')
        log.info "Node Acceptance Output = #{output}"
        output == "PASS"
      end
    end
  end
end
