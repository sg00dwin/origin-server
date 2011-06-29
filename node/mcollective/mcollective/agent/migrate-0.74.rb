require 'rubygems'
require 'open4'
require 'fileutils'
require 'parseconfig'
require 'pp'

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
      if contains_value?(post_receive, 'curl -s -O /dev/null -d')
        output += "post-receive located at '#{post_receive}' already contains the necessary nurture curl\n"
      else
        nurture_curl = "curl -s -O /dev/null -d \"json_data=\\\"{\\\"app_uuid\\\":\\\"#{uuid}\\\",\\\"action\\\":\\\"push\\\"}\\\"\" https://#{libra_server}/broker/nurture >/dev/null 2>&1 &"
        output += append_to_file(post_receive, nurture_curl)
      end
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
  
  def self.append_to_file(f, value)
    file = File.open(f, 'a')
    begin
      file.puts ""
      file.puts value
    ensure
      file.close
    end
    return "Appended '#{value}' to '#{file}'"
  end
  
  def self.contains_value?(f, value)
    file = File.open(f, 'r')
    begin
      file.each {|line| return true if line.include? value}
    ensure
      file.close
    end
    false
  end
end