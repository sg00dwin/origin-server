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
        
      jenkins_url = nil
      orig_jenkins_url = nil
      if File.exists?("#{app_home}/.env/JENKINS_URL")
        jenkins_url = Util.get_env_var_value(app_home, "JENKINS_URL")
        if jenkins_url.start_with?("http://")
          orig_jenkins_url = jenkins_url
          jenkins_url = "https://#{jenkins_url[7..-1]}"
          env_echos.push("echo \"export JENKINS_URL='#{jenkins_url}'\" > #{app_home}/.env/JENKINS_URL")
        end
      end

      if app_type == 'jenkins-1.4'
        #Util.replace_in_file("#{app_dir}/data/jobs/*/config.xml", "<builderType>raw-0.1</builderType>", "<builderType>diy-0.1</builderType>")
        if orig_jenkins_url
          Util.replace_in_file("#{app_dir}/data/config.xml", "<jenkinsUrl>.*</jenkinsUrl>", "")
          #Util.replace_in_file("#{app_dir}/data/hudson.tasks.Mailer.xml", "<hudsonUrl>.*</hudsonUrl>", "<hudsonUrl>#{jenkins_url}</hudsonUrl>")
        end
      end

      env_echos.each do |env_echo|
        echo_output, echo_exitcode = Util.execute_script(env_echo)
        output += echo_output
      end

      echo_output, echo_exitcode = Util.execute_script("/usr/bin/rhc-app-gear-xlate #{app_home}/.env")
      output += echo_output

    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
