require 'rubygems'
require 'fileutils'
require 'parseconfig'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"

module LibraMigration

  def self.migrate(uuid, app_name, app_type, namespace, version)
    node_config = ParseConfig.new('/etc/stickshift/stickshift-node.conf')
    libra_home = '/var/lib/stickshift' #node_config.get_value('libra_dir')
    libra_server = node_config.get_value('BROKER_HOST')
    libra_domain = node_config.get_value('CLOUD_DOMAIN')
    app_home = "#{libra_home}/#{uuid}"
    app_dir = "#{app_home}/#{app_name}"
    output = ''
    exitcode = 0
    if (File.exists?(app_home) && !File.symlink?(app_home))
      cartridge_root_dir = "/usr/libexec/stickshift/cartridges"
      cartridge_dir = "#{cartridge_root_dir}/#{app_type}"

      env_echos = []

      if app_type == 'jenkins-1.4'
        #Util.replace_in_file("#{app_dir}/data/jobs/*/config.xml", "<builderType>raw-0.1</builderType>", "<builderType>diy-0.1</builderType>")
      end

      env_echos.each do |env_echo|
        echo_output, echo_exitcode = Util.execute_script(env_echo)
        output += echo_output
      end

    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
