module MCollective
    module Agent
        class Libra<RPC::Agent
            metadata    :name        => "Libra Management",
                        :description => "Agent to manage Libra services",
                        :author      => "Mike McGrath",
                        :license     => "GPLv2",
                        :version     => "0.1",
                        :url         => "https://engineering.redhat.com/trac/Libra",
                        :timeout     => 60

            # Basic echo server
            def echo_action
                validate :msg, String
                reply[:msg] = request[:msg]
            end
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
            def create_http_action
                validate :customer, /^[a-zA-Z0-9]+$/
                validate :application, /^[a-zA-Z0-9]+$/
                customer = request[:customer]
                application = request[:application]

                reply.fail! "Cannot find create_http.sh" unless File.exist?("/usr/local/bin/libra/create_http.sh")
                reply[:output] = %x[/usr/local/bin/libra/create_http.sh -c #{customer} -a #{application} 2>&1]
                reply[:exitcode] = $?.exitstatus
                reply.fail! "create_http failed #{reply[:exitcode]}" unless reply[:exitcode] == 0
            end
            def destroy_http_action
                validate :customer, /^[a-zA-Z0-9]+$/
                validate :application, /^[a-zA-Z0-9]+$/
                customer = request[:customer]
                application = request[:application]

                reply.fail! "Cannot find destroy_http.sh" unless File.exist?("/usr/local/bin/libra/destroy_http.sh")
                reply[:output] = %x[/usr/local/bin/libra/destroy_http.sh -c #{customer} -a #{application} 2>&1]
                reply[:exitcode] = $?.exitstatus
                reply.fail! "destroy_http failed #{reply[:exitcode]}" unless reply[:exitcode] == 0
            end
            def create_git_action
                validate :customer, /^[a-zA-Z0-9]+$/
                validate :application, /^[a-zA-Z0-9]+$/
                customer = request[:customer]
                application = request[:application]

                reply.fail! "Cannot find create_git.sh" unless File.exist?("/usr/local/bin/libra/create_git.sh")
                reply[:output] = %x[/usr/local/bin/libra/create_git.sh -c #{customer} -a #{application} 2>&1]
                reply[:exitcode] = $?.exitstatus
                reply.fail! "create_git failed #{reply[:exitcode]}" unless reply[:exitcode] == 0
            end
        end
    end
end

