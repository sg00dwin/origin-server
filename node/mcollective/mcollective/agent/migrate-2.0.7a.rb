require 'rubygems'
require 'fileutils'
require 'parseconfig'
require 'pp'
require 'find'
require 'selinux'
require File.dirname(__FILE__) + "/migrate-util"

module LibraMigration

  def self.get_config_value(key)
    @node_config ||= ParseConfig.new('/etc/stickshift/stickshift-node.conf')
    val = @node_config.get_value(key)
    val.gsub!(/\\:/,":") if not val.nil?
    val.gsub!(/[ \t]*#[^\n]*/,"") if not val.nil?
    val = val[1..-2] if not val.nil? and val.start_with? "\""
    val
  end

  def self.migrate(uuid, app_name, app_type, namespace, version)

    libra_home = '/var/lib/stickshift' #node_config.get_value('libra_dir')
    libra_server = get_config_value('BROKER_HOST')
    libra_domain = get_config_value('CLOUD_DOMAIN')
    app_home = "#{libra_home}/#{uuid}"
    app_dir = "#{app_home}/#{app_name}"
    output = ''
    exitcode = 0
    if (File.exists?(app_home) && !File.symlink?(app_home))
      cartridge_root_dir = "/usr/libexec/stickshift/cartridges"
      cartridge_dir = "#{cartridge_root_dir}/#{app_type}"

      env_echos = []


      env_echos.each do |env_echo|
        echo_output, echo_exitcode = Util.execute_script(env_echo)
        output += echo_output
      end

      # Fix app variables
      echo_output, echo_exitcode = Util.execute_script("/usr/bin/rhc-app-gear-xlate #{app_home}/.env")
      output += echo_output

      # Fix symlinks inside the app, and top level symlink (only on dev?).
      # Don't mess with the git repo.
      path_conversions={
        '/var/lib/libra'  => '/var/lib/stickshift',
        '/var/libexec/li' => '/var/libexec/stickshift'
      }
      path_forbidden=["#{app_home}/git"]

      Find.find(app_home) do |path|
        stat=File.lstat(path)
        context=Selinux.lgetfilecon(path)

        path_forbidden.each do |nopath|
          nostat=File.lstat(nopath)
          if (stat.dev == nostat.dev) and (stat.ino == nostat.ino)
            Find.prune # Start the next iteration of find
          end
        end

        if File.symlink?(path)
          link_targ=File.readlink(path)
          new_targ=String.new(link_targ)
          path_conversions.each do |orig_path, dst_path|
            while new_targ[orig_path] != nil
              new_targ[orig_path]=dst_path
            end
          end
          if link_targ!=new_targ
            File.unlink(path)
            File.symlink(new_targ, path)
            File.lchown(stat.uid, stat.gid, path)
            # File.lchmod(stat.mode & 0777, path) # Not implemented on RHEL 6
            Selinux.lsetfilecon(path, context[1])
          end
        end

      end


    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
