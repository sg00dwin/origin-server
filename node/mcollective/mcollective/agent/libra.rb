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
require 'fileutils'
require 'pp'

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
                  :timeout     => 60

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
        validate :cartridge, /^[a-zA-Z0-9\.\-]+$/
        validate :action, /^(configure|deconfigure|update_namespace|info|post-install|post_remove|pre-install|reload|restart|start|status|stop)$/
        validate :args, /^.+$/
        cartridge = request[:cartridge]
        action = request[:action]
        args = request[:args]
        if File.exists? "/usr/libexec/li/cartridges/#{cartridge}/info/hooks/#{action}"                
          pid, stdin, stdout, stderr = Open4::popen4("/usr/bin/runcon -l s0-s0:c0.c1023 /usr/libexec/li/cartridges/#{cartridge}/info/hooks/#{action} #{args} 2>&1")
        else
          reply[:exitcode] = 127
          reply.fail! "cartridge_do_action ERROR action '#{action}' not found."
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
        uuid = request[:uuid]
        app_name = request[:application]
        old_app_type = request[:app_type]
        version = request[:version]
        libra_home = '/var/lib/libra'
        cartridge_dir = "/usr/libexec/li/cartridges"
        output = ""
        exitcode = 0
        app_types = {'php-5.3.2' => 'php-5.3', 
                     'rack-1.1.0' => 'rack-1.0', 
                     'wsgi-3.2.1' => 'wsgi-3.2',
                     'jbossas-7.0.0' => 'jbossas-7.0',
                     'perl-5.10.1' => 'perl-5.10'}
        new_app_type = app_types[old_app_type]
        if (version == '0.72.9')
          framework = old_app_type.split('-')[0]
          app_home = "#{libra_home}/#{uuid}"
          framework_dir = "#{app_home}/#{framework}"
          old_app_dir = "#{framework_dir}/#{app_name}"
          new_app_dir = "#{app_home}/#{app_name}"
          if File.exists? old_app_dir
            output += "Moving '#{old_app_dir}' to '#{new_app_dir}'\n"
            FileUtils.mv old_app_dir, new_app_dir
            if Dir["#{framework_dir}/*"].empty?
              output += "Removing empty app type dir '#{framework_dir}'\n"
              FileUtils.remove_dir framework_dir
            end
            ctl_script = "#{new_app_dir}/#{app_name}_ctl.sh"
            replace_in_file(ctl_script, old_app_dir, new_app_dir)
            output += "Updating '#{ctl_script}' from #{old_app_type} to #{new_app_type}\n"
            system("sed -i \"s,#{cartridge_dir}/#{old_app_type},#{cartridge_dir}/#{new_app_type},g\" #{ctl_script}")
            replace_in_file(ctl_script, "#{cartridge_dir}/#{old_app_type}", "#{cartridge_dir}/#{new_app_type}")
            replace_in_file("#{new_app_dir}/conf.d/libra.conf", old_app_dir, new_app_dir)
            replace_in_file("#{app_home}/git/#{app_name}.git/hooks/post-receive", old_app_dir, new_app_dir)
            if framework == 'php'
              replace_in_file("#{new_app_dir}/conf/php.ini", old_app_dir, new_app_dir)
            end
          else
            exitcode = 127
            output += "Application not found to migrate: #{uuid}/#{framework}/#{app_name}\n"
          end
        else
          exitcode = 127
          output += "Migration version not supported: #{version}\n"
        end
        Log.instance.debug("migrate_action (#{exitcode})\n------\n#{output}\n------)")

        reply[:output] = output
        reply[:exitcode] = exitcode
        reply.fail! "migrate_action failed #{exitcode}.  Output #{output}" unless exitcode == 0
      end
      
      def replace_in_file(file, old_value, new_value)
        output += "Updating '#{file}' changing '#{old_value}' to '#{new_value}'\n"
        system("sed -i \"s,#{old_value},#{new_value},g\" #{file}")
      end

      #
      # Returns whether an app is on a server
      #
      def has_app_action
        validate :uuid, /^[a-zA-Z0-9]+$/
        validate :application, /^[a-zA-Z0-9]+$/
        uuid = request[:uuid]
        app_name = request[:application]
        if File.exist?("/var/lib/libra/#{uuid}/#{app_name}")
          reply[:output] = true
        else
          reply[:output] = false
        end
        reply[:exitcode] = 0
      end

    end
  end
end

