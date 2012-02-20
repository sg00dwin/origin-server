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
      cartridge_dir = "#{cartridge_root_dir}/#{app_type}"

      if app_type == 'jenkins-1.4' 
        config_xml = "#{app_dir}/data/config.xml"
        config_xml_contents = Util.file_to_string(config_xml)
  
        output += "Migrating jenkins config.xml: #{config_xml}\n"
  
        users = Dir.glob("#{app_dir}/data/users/*").map do |user_path|
          File.basename(user_path)
        end
  
        lines = config_xml_contents.split('\n')
        file = File.open(config_xml, 'w')
        begin
          lines.each do |line|
            if line =~ /<authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy"\/> *$/
              file.puts "  <authorizationStrategy class=\"hudson.security.GlobalMatrixAuthorizationStrategy\">"
              users.each do |user|
                file.puts "    <permission>hudson.model.Computer.Configure:#{user}</permission>"
                file.puts "    <permission>hudson.model.Computer.Delete:#{user}</permission>"
                file.puts "    <permission>hudson.model.Hudson.Administer:#{user}</permission>"
                file.puts "    <permission>hudson.model.Hudson.Read:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Build:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Configure:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Create:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Delete:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Read:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Workspace:#{user}</permission>"
                file.puts "    <permission>hudson.model.Run.Delete:#{user}</permission>"
                file.puts "    <permission>hudson.model.Run.Update:#{user}</permission>"
                file.puts "    <permission>hudson.model.View.Configure:#{user}</permission>"
                file.puts "    <permission>hudson.model.View.Create:#{user}</permission>"
                file.puts "    <permission>hudson.model.View.Delete:#{user}</permission>"
                file.puts "    <permission>hudson.scm.SCM.Tag:#{user}</permission>"
              end
              file.puts "  </authorizationStrategy>"
            else
              file.puts line
            end
          end
        ensure
          file.close
        end
      end
      
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
