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
        Log.instance.debug("cartridge_do_action validation = #{request[:cartridge]} #{request[:action]} #{request[:args]}")
        validate :cartridge, /\A[a-zA-Z0-9\.\-\/]+\z/
        validate :cartridge, :shellsafe
        validate :action, /\A(configure|deconfigure|update_namespace|info|post-install|post_remove|pre-install|reload|restart|start|status|stop)\Z/
        validate :action, :shellsafe
        validate :args, /\A[\w\+\/= @\-\.]+\z/
        validate :args, :shellsafe
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
      
      #
      # Returns whether an embedded app is on a server
      #
      def has_embedded_app_action
        validate :uuid, /^[a-zA-Z0-9]+$/
        validate :embedded_type, /^.+$/
        uuid = request[:uuid]
        embedded_type = request[:embedded_type]
        if File.exist?("/var/lib/libra/#{uuid}/#{embedded_type}")
          reply[:output] = true
        else
          reply[:output] = false
        end
        reply[:exitcode] = 0
      end

    end
  end
end

