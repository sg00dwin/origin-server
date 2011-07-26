require 'rubygems'
require 'fileutils'
require 'parseconfig'
require 'pp'
require 'migrate-util'

module LibraMigration

  def self.migrate(uuid, app_name, app_type, namespace, version)
    node_config = ParseConfig.new('/etc/libra/node.conf')
    libra_home = '/var/lib/libra' #node_config.get_value('libra_dir')
    libra_server = node_config.get_value('libra_server')
    app_home = "#{libra_home}/#{uuid}"
    app_dir = "#{app_home}/#{app_name}"
    output = ''
    exitcode = 0
    if (File.exists?(app_home) && !File.symlink?(app_home))
      post_receive = "#{app_home}/git/#{app_name}.git/hooks/post-receive"
      ctl_script = "#{app_dir}/#{app_name}_ctl.sh"
      begin
      output += replace_in_file(post_receive, '//', '/')
      output += replace_in_file(post_receive, "hello", "world")
      rescue Exception => e
        output += e.message
      end
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end