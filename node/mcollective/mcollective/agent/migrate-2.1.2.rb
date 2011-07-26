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
    app_dir = "#{app_home}/#{app_name}"
    output = ''
    exitcode = 0
    if (File.exists?(app_home) && !File.symlink?(app_home))
      post_receive = "#{app_home}/git/#{app_name}.git/hooks/post-receive"
      ctl_script = "#{app_dir}/#{app_name}_ctl.sh"
      libra_conf = "#{app_dir}/conf.d/libra.conf"
      if (app_type == 'rack-1.1')
        output += Util.replace_in_file(libra_conf, "^PassengerTempDir .*", "")
        output += Util.replace_in_file(libra_conf, "^PassengerAnalyticsLogDir .*", "")
      end
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end