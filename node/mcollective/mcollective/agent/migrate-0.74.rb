require 'rubygems'
require 'fileutils'
require 'parseconfig'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"

module LibraMigration

  def self.migrate(uuid, app_name, app_type, namespace, version)
    node_config = ParseConfig.new('/etc/libra/node.conf')
    libra_home = '/var/lib/libra' #node_config.get_value('libra_dir')
    libra_server = node_config.get_value('libra_server')
    app_home = "#{libra_home}/#{uuid}"
    #app_dir = "#{app_home}/#{app_name}"
    output = ''
    exitcode = 0
    if (File.exists?(app_home) && !File.symlink?(app_home))
      post_receive = "#{app_home}/git/#{app_name}.git/hooks/post-receive"
      if Util.contains_value?(post_receive, 'curl -s -O /dev/null -d')
        output += "post-receive located at '#{post_receive}' already contains the necessary nurture curl\n"
      else
        nurture_curl = "curl -s -O /dev/null -d \"json_data=\\\"{\\\"app_uuid\\\":\\\"#{uuid}\\\",\\\"action\\\":\\\"push\\\"}\\\"\" https://#{libra_server}/broker/nurture >/dev/null 2>&1 &"
        output += Util.append_to_file(post_receive, nurture_curl)
      end
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end