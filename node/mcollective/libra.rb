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
                validate :cartridge, /^[a-zA-Z0-9\.\-]+$/
                validate :action, /^(configure|deconfigure|info|post-install|post_remove|pre-install|reload|restart|start|status|stop)$/
                validate :args, /^.+$/
                cartridge = request[:cartridge]
                action = request[:action]
                args = request[:args]
                reply[:output] = %x[/usr/bin/runcon -l s0-s0:c0.c1023 /usr/libexec/li/cartridges/#{cartridge}/info/hooks/#{action} #{args} 2>&1 ]
                reply[:exitcode] = $?.exitstatus
                reply.fail! "cartridge_action failed #{reply[:exitcode]}.  Output #{reply[:output]}" unless reply[:exitcode] == 0
            end
            #
            # Creates a new customer.
            # Creates username.
            # Creates home dir structure.
            # Adds ssh key.
            #
            def create_customer_action
                validate :customer, /^[a-zA-Z0-9]+$/
                validate :email, /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
                validate :ssh_key, String
                customer = request[:customer]
                email = request[:email]
                ssh_key = request[:ssh_key]
                reply.fail! "#{customer} Already exists" if File.exist?("/var/lib/libra/#{customer}")
                reply[:output] = %x[/usr/local/bin/libra/create_customer.sh -c #{customer} -e #{email} -s #{ssh_key} 2>&1]
                reply[:exitcode] = $?.exitstatus
                reply.fail! "create_customer failed #{reply[:exitcode]}" unless reply[:exitcode] == 0
            end
            #
            # Creates http environment for customer to use
            #
            def create_http_action
                execute_script('create_http')
            end
            #
            # Destroys (deletes) http environment
            #
            def destroy_http_action
                execute_script('destroy_http')
            end
            #
            # Creates git repo for a customer
            #
            def create_git_action
                execute_script('create_git')
            end

            #
            # Executes an action
            #
            def execute_script(script)
                validate :customer, /^[a-zA-Z0-9]+$/
                validate :application, /^[a-zA-Z0-9]+$/
                customer = request[:customer]
                application = request[:application]

                reply.fail! "Cannot find #{script}.sh" unless File.exist?("/usr/local/bin/libra/#{script}.sh")
                reply[:output] = %x[/usr/local/bin/libra/#{script}.sh -c #{customer} -a #{application} 2>&1]
                reply[:exitcode] = $?.exitstatus
                reply.fail! "#{script} failed #{reply[:exitcode]}" unless reply[:exitcode] == 0
            end
        end
    end
end

