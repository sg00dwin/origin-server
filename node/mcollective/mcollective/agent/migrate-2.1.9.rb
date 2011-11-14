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
    libra_domain = node_config.get_value('libra_domain')
    app_home = "#{libra_home}/#{uuid}"
    app_dir = "#{app_home}/#{app_name}"
    output = ''
    exitcode = 0
    if (File.exists?(app_home) && !File.symlink?(app_home))
      #cartridge_root_dir = "/usr/libexec/li/cartridges"
      #cartridge_dir = "#{cartridge_root_dir}/#{app_type}"

      output += "Testing\n"
=begin
      git_dir = "#{app_home}/git/#{app_name}.git/"
      FileUtils.chown(uuid, uuid, git_dir)
      FileUtils.chmod(0755, git_dir)
      
      gitconfig = "#{app_home}/.gitconfig"
      output += "Migrating .gitconfig: #{gitconfig}\n"
      file = File.open(gitconfig, 'w')
      begin
        file.puts <<EOF
[user]
  name = OpenShift System User
[gc]
  auto = 100
EOF
      ensure
        file.close
      end
=end
      
      FileUtils.chown('root', 'root', gitconfig)
      FileUtils.chmod(0755, gitconfig)
      
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
