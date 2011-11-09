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
      cartridge_root_dir = "/usr/libexec/li/cartridges"
      #cartridge_dir = "#{cartridge_root_dir}/#{app_type}"

      phpmyadmin_dir = "#{app_home}/phpmyadmin-3.4"
      if File.exists?(phpmyadmin_dir)
         phpmyadmin_cartridge_root_dir = "/usr/libexec/li/cartridges/embedded/phpmyadmin-3.4"
         FileUtils.ln_s  "#{phpmyadmin_cartridge_root_dir}/info/configuration/disabled_pages.conf", "#{phpmyadmin_dir}/conf.d/disabled_pages.conf"
      end
      
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
