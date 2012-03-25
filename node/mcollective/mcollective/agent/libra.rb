# -*- coding: utf-8 -*-
# = libra.rb: li integration for mcollective
#
# Author:: Mike McGrath
#
# Copyright © 2010 Mike McGrath All rights reserved
# Copyright © 2010 Red Hat, Inc. All rights reserved
#
# This copyrighted material is made available to anyone wishing to use, modify,
# copy, or redistribute it subject to the terms and conditions of the GNU
# General Public License v.2.  This program is distributed in the hope that it
# will be useful, but WITHOUT ANY WARRANTY expressed or implied, including the
# implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.  You should have
# received a copy of the GNU General Public License along with this program;
# if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
# Fifth Floor, Boston, MA 02110-1301, USA. Any Red Hat trademarks that are
# incorporated in the source code or documentation are not subject to the GNU
# General Public License and may only be used or replicated with the express
# permission of Red Hat, Inc.
#
# == Description
#
# libra.rb for mcollective does manipulation of libra services and customer
# data.  This can start and stop services, create and destroy applications
# as well as create new customers.
#
require 'rubygems'
require 'open4'
require 'pp'
require 'json'

module MCollective
  #
  # Li mcollective agent
  #
  module Agent
  
    class Libra<RPC::Agent
      metadata    :name        => "Libra Management",
                  :description => "Agent to manage Libra services",
                  :author      => "Mike McGrath",
                  :license     => "GPLv2",
                  :version     => "0.1",
                  :url         => "https://engineering.redhat.com/trac/Libra",
                  :timeout     => 240

      #
      # Simple echo method
      #
      def echo_action
        validate :msg, String
        reply[:msg] = request[:msg]
      end

      #
      # Passes arguments to cartridge for use
      #
      def cartridge_do_action
        Log.instance.debug("cartridge_do_action call / request = #{request.pretty_inspect}")
        Log.instance.debug("cartridge_do_action validation = #{request[:cartridge]} #{request[:action]} #{request[:args]}")
        validate :cartridge, /\A[a-zA-Z0-9\.\-\/]+\z/
        validate :cartridge, :shellsafe
        validate :action, /\A(app-create|app-destroy|env-var-add|env-var-remove|broker-auth-key-add|broker-auth-key-remove|authorized-ssh-key-add|authorized-ssh-key-remove|configure|deconfigure|preconfigure|update-namespace|tidy|deploy-httpd-proxy|remove-httpd-proxy|move|pre-move|post-move|info|post-install|post-remove|pre-install|reload|restart|start|status|stop|force-stop|add-alias|remove-alias|threaddump|cartridge-list|expose-port|conceal-port|show-port|system-messages|connector-execute)\Z/
        validate :action, :shellsafe
        validate :args, /\A[\w\+\/= \{\}\"@\-\.:;\'\\\n~,]+\z/
        validate :args, :shellsafe
        cartridge = request[:cartridge]
        action = request[:action]
        args = request[:args]
        pid, stdin, stdout, stderr = nil, nil, nil, nil
        if cartridge == 'stickshift-node'
          cmd = "ss-#{action}"
          pid, stdin, stdout, stderr = Open4::popen4("/usr/bin/runcon -l s0-s0:c0.c1023 #{cmd} #{args} 2>&1")
        else
          if File.exists? "/usr/libexec/stickshift/cartridges/#{cartridge}/info/hooks/#{action}"                
            pid, stdin, stdout, stderr = Open4::popen4ext(true, "/usr/bin/runcon -l s0-s0:c0.c1023 /usr/libexec/stickshift/cartridges/#{cartridge}/info/hooks/#{action} #{args} 2>&1")
            #pid, stdin, stdout, stderr = Open4::popen4("/usr/bin/runcon -l s0-s0:c0.c1023 /usr/libexec/stickshift/cartridges/#{cartridge}/info/hooks/#{action} #{args} 2>&1")
          elsif File.exists? "/usr/libexec/stickshift/cartridges/embedded/#{cartridge}/info/hooks/#{action}"                
            pid, stdin, stdout, stderr = Open4::popen4ext(true, "/usr/bin/runcon -l s0-s0:c0.c1023 /usr/libexec/stickshift/cartridges/embedded/#{cartridge}/info/hooks/#{action} #{args} 2>&1")
          else
            reply[:exitcode] = 127
            reply.fail! "cartridge_do_action ERROR action '#{action}' not found."
          end
        end
        stdin.close
        ignored, status = Process::waitpid2 pid
        exitcode = status.exitstatus
        # Do this to avoid cartridges that might hold open stdout
        output = ""
        begin
          Timeout::timeout(5) do
            while (line = stdout.gets)
              output << line
            end
          end
        rescue Timeout::Error
          Log.instance.debug("cartridge_do_action WARNING - stdout read timed out")
        end

        if exitcode == 0
          Log.instance.debug("cartridge_do_action (#{exitcode})\n------\n#{output}\n------)")
        else
          Log.instance.debug("cartridge_do_action ERROR (#{exitcode})\n------\n#{output}\n------)")
        end

        reply[:output] = output
        reply[:exitcode] = exitcode
        reply.fail! "cartridge_do_action failed #{exitcode}.  Output #{output}" unless exitcode == 0
      end
        
      #
      # Migrate between versions
      #
      def migrate_action
        Log.instance.debug("migrate_action call / request = #{request.pretty_inspect}")
        validate :uuid, /^[a-zA-Z0-9]+$/
        validate :application, /^[a-zA-Z0-9]+$/
        validate :app_type, /^.+$/
        validate :version, /^.+$/
        validate :namespace, /^.+$/  
        uuid = request[:uuid]
        app_name = request[:application]
        old_app_type = request[:app_type]
        namespace = request[:namespace]
        version = request[:version]
        output = ""
        exitcode = 0
        begin
          require "#{File.dirname(__FILE__)}/migrate-#{version}"
          output, exitcode = LibraMigration::migrate(uuid, app_name, old_app_type, namespace, version)
        rescue LoadError => e
          exitcode = 127
          output += "Migration version not supported: #{version}\n"
        rescue Exception => e
          exitcode = 1
          output += "Application failed to migrate with exception: #{e.message}\n#{e.backtrace}\n"
        end
        Log.instance.debug("migrate_action (#{exitcode})\n------\n#{output}\n------)")

        reply[:output] = output
        reply[:exitcode] = exitcode
        reply.fail! "migrate_action failed #{exitcode}.  Output #{output}" unless exitcode == 0
      end
      
      #
      # Set the district for a node
      #
      def set_district_action
        Log.instance.debug("set_district call / request = #{request.pretty_inspect}")
        validate :uuid, /^[a-zA-Z0-9]+$/
        uuid = request[:uuid]
        active = request[:active]

        output = `echo "#Do not modify manually!\nuuid='#{uuid}'\nactive='#{active}'" > /etc/stickshift/district.conf`
        exitcode = $?.exitstatus

        if exitcode == 0
          Facter.add(:district_uuid) do
              setcode { uuid }
          end
          Facter.add(:district_active) do
              setcode { active }
          end
        end

        Log.instance.debug("set_district (#{exitcode})\n------\n#{output}\n------)")

        reply[:output] = output
        reply[:exitcode] = exitcode
        reply.fail! "set_district failed #{exitcode}.  Output #{output}" unless exitcode == 0
      end

      #
      # Returns whether an app is on a server
      #
      def has_app_action
        validate :uuid, /^[a-zA-Z0-9]+$/
        validate :application, /^[a-zA-Z0-9]+$/
        uuid = request[:uuid]
        app_name = request[:application]
        if File.exist?("/var/lib/stickshift/#{uuid}/#{app_name}")
          reply[:output] = true
        else
          reply[:output] = false
        end
        reply[:exitcode] = 0
      end
      
      #
      # Returns whether an embedded app is on a server
      #
      def has_embedded_app_action
        validate :uuid, /^[a-zA-Z0-9]+$/
        validate :embedded_type, /^.+$/
        uuid = request[:uuid]
        embedded_type = request[:embedded_type]
        if File.exist?("/var/lib/stickshift/#{uuid}/#{embedded_type}")
          reply[:output] = true
        else
          reply[:output] = false
        end
        reply[:exitcode] = 0
      end
      
      #
      # Returns whether a uid or gid is already reserved on the system
      #
      def has_uid_or_gid_action
        validate :uid, /^[0-9]+$/
        uid = request[:uid].to_i

        uids = IO.readlines("/etc/passwd").map{ |line| line.split(":")[2].to_i }
        gids = IO.readlines("/etc/group").map{ |line| line.split(":")[2].to_i }

        if uids.include?(uid) || gids.include?(uid)
          reply[:output] = true
        else
          reply[:output] = false
        end
        reply[:exitcode] = 0
      end

      #
      # Get all gears
      #
      def get_all_gears_action
        gear_map = request[:gear_map]

        uid_map = {}
        uids = IO.readlines("/etc/passwd").map{ |line| 
          uid = line.split(":")[2]
          username = line.split(":")[0]
          uid_map[username] = uid
        }
        dir = "/var/lib/stickshift/"
        filelist = Dir.foreach(dir) { |file| 
          if File.directory?(dir+file) and not File.symlink?(dir+file) and not file[0]=='.'
            if uid_map.has_key?(file)
              gear_map[file] = uid_map[file]
            end
          end
        }
        reply[:output] = gear_map
        reply[:exitcode] = 0
      end

      #
      # Executes a list of jobs parallely and returns their results embedded in args
      #
      def execute_parallel_action        
        Log.instance.debug("execute_parallel_action call / request = #{request.pretty_inspect}")
        #validate :joblist, /\A[\w\+\/= \{\}\"@\-\.:\'\\\n~,_]+\z/
        #validate :joblist, :shellsafe

        joblist = request[config.identity]
        pidlist = []
        joblist.each { |parallel_job|
          job = parallel_job[:job]
          cartridge = job[:cartridge]
          action = job[:action]
          args = job[:args]
          begin
            pid, stdout, stderr = execute_parallel_job(cartridge, action, args)
          rescue Exception =>e
            parallel_job[:result_exit_code] = 127
            parallel_job[:result_stdout] = e.message
            parallel_job[:result_stderr] = e.message
            next
          end
          pidlist << [parallel_job, pid, stdout, stderr]
        }

        pidlist.each { |reap_args|
          pj, pid, sout, serr = reap_args
          reap_output(pj, pid, sout, serr)
        }
        Log.instance.debug("execute_parallel_action call - 10 #{joblist}")
        reply[:output] = joblist
        reply[:exitcode] = 0
      end

      def execute_parallel_job(cartridge, action, args)
        pid, stdin, stdout, stderr = nil, nil, nil, nil
        if cartridge == 'stickshift-node'
          cmd = "ss-#{action}"
          pid, stdin, stdout, stderr = Open4::popen4("/usr/bin/runcon -l s0-s0:c0.c1023 #{cmd} #{args} 2>&1")
        else
          if File.exists? "/usr/libexec/stickshift/cartridges/#{cartridge}/info/hooks/#{action}"                
            pid, stdin, stdout, stderr = Open4::popen4ext(true, "/usr/bin/runcon -l s0-s0:c0.c1023 /usr/libexec/stickshift/cartridges/#{cartridge}/info/hooks/#{action} #{args} 2>&1")
            #pid, stdin, stdout, stderr = Open4::popen4("/usr/bin/runcon -l s0-s0:c0.c1023 /usr/libexec/stickshift/cartridges/#{cartridge}/info/hooks/#{action} #{args} 2>&1")
          elsif File.exists? "/usr/libexec/stickshift/cartridges/embedded/#{cartridge}/info/hooks/#{action}"                
            pid, stdin, stdout, stderr = Open4::popen4ext(true, "/usr/bin/runcon -l s0-s0:c0.c1023 /usr/libexec/stickshift/cartridges/embedded/#{cartridge}/info/hooks/#{action} #{args} 2>&1")
          else
            raise Exception.new("cartridge_do_action ERROR action '#{action}' not found.")
          end
        end
        stdin.close
        return pid, stdout, stderr
      end

      def reap_output(parallel_job, pid, stdout, stderr)
        ignored, status = Process::waitpid2 pid
        exitcode = status.exitstatus
        # Do this to avoid cartridges that might hold open stdout
        output = ""
        begin
          Timeout::timeout(5) do
            while (line = stdout.gets)
              output << line
            end
          end
        rescue Timeout::Error
          Log.instance.debug("cartridge_do_action WARNING - stdout read timed out")
        end

        if exitcode == 0
          Log.instance.debug("cartridge_do_action (#{exitcode})\n------\n#{output}\n------)")
        else
          Log.instance.debug("cartridge_do_action ERROR (#{exitcode})\n------\n#{output}\n------)")
        end

        parallel_job[:result_stdout] = output
        parallel_job[:result_exit_code] = exitcode
      end
    end
  end
end
