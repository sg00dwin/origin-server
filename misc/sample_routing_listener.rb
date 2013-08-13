#!/usr/bin/ruby

##
# Sample routing listener for nginx
#  Step 1 : Listen to activemq topic 'routinginfo'. 
#           Note that the activemq routing plugin has to be configured with the same creds (routinginfo/routinginfopasswd)
#           Also note that host/port are hardcoded in this script
#  Step 2 : Look for add_gear/HAPROXY_PROXY_PORT message on the topic and add/edit nginx config file
#           Look for delete_gear/HAPROXY_PROXY_PORT message and edit the nginx config file
#           Look for delete_application message and remove the nginx config file
##
           
require 'rubygems'
require 'stomp'
require 'yaml'

CONF_DIR='/etc/nginx/conf.d/'

def add_haproxy(appname, namespace, ip, port)
  scope = "#{appname}-#{namespace}"
  file = File.join(CONF_DIR, "#{scope}.conf")
  if File.exist?(file)
    `sed -i 's/upstream #{scope} {/&\n      server #{ip}:#{port}' #{file}`
  else
    # write a new one
    template = <<-EOF
    upstream #{scope} {
      server #{ip}:#{port};
    }
    server {
      listen 8000;
      server_name ha-#{scope}.dev.rhcloud.com;
      location / {
        proxy_pass http://#{scope};
      }
    }
EOF
    File.open(file, 'w') { |f| f.write(template) }
  end
  `nginx -s reload`
end


c = Stomp::Client.new("routinginfo", "routinginfopasswd", "localhost", 6163, true)
c.subscribe('/topic/routinginfo') { |msg|
  h = YAML.load(msg.body)
  if h[:action] == :add_gear 
    if h[:public_port_name]=="OPENSHIFT_HAPROXY_PROXY_PORT"
       add_haproxy(h[:app_name], h[:namespace], h[:public_address], h[:public_port])
       puts "Added routing endpoint for #{h[:app_name]}-#{h[:namespace]}"
    end
  elsif h[:action] == :delete_gear
  elsif h[:action] == :delete_application
     scope = '#{h[:app_name]}-#{h[:namespace]}'
     file = File.join(CONF_DIR, "#{scope}.conf")
     if File.exist?(file)
       `rm -f #{file}`
       `nginx -s reload`
       puts "Removed configuration for #{scope}"
     end
  end
}
c.join

