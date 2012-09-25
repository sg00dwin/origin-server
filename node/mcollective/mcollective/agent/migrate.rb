require 'rubygems'
require 'etc'
require 'fileutils'
require 'socket'
require 'parseconfig'
require 'selinux'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"

module OpenShiftMigration

  def self.get_config_value(key)
    @node_config ||= ParseConfig.new('/etc/stickshift/stickshift-node.conf')
    val = @node_config.get_value(key)
    val.gsub!(/\\:/,":") if not val.nil?
    val.gsub!(/[ \t]*#[^\n]*/,"") if not val.nil?
    val = val[1..-2] if not val.nil? and val.start_with? "\""
    val
  end


  # Transformations on namespace
  def self.mongodb_xform_ent(input)
    output=input.clone
    { "mongodb-2.0" => "mongodb-2.2", "MONGODB_20" => "MONGODB_22" }.each do |src,dst|
      output.gsub!(src,dst)
    end
    if input != output
      yield output
    end
    return output
  end



  # Handle gear conversion from mongodb-2.0 to mongodb-2.2
  def self.migrate_mongodb_22(uuid, gear_home, gear_name)
    output = ""

    # Check if called on a gear of an app that has mongodb.
    # This test is not altered by the migration.
    nosql_type=""
    [ File.join(gear_home, ".env", "OPENSHIFT_NOSQL_DB_TYPE"),
      File.join(gear_home, ".env", ".uservars", "OPENSHIFT_NOSQL_DB_TYPE") ].each do |envfile|
      begin
        File.open(envfile) do |f|
          nosql_type=f.read
          nosql_type.strip!
          nosql_type.sub!(/^.*=/,'')
          nosql_type.gsub!('\'','')
        end
      rescue Errno::ENOENT
      end
    end

    return unless nosql_type[0,7] == "mongodb"

    output+="Mongodb migration for gear #{uuid}\n"

    # The mongodb-2.0 directory must be ahead of its subdirectories
    [ File.join(gear_home, "mongodb-2.0"),
      File.join(gear_home, gear_name),
      File.join(gear_home, "mongodb-2.0", "etc", "mongodb.conf"),
      File.join(gear_home, "mongodb-2.0", "#{gear_name}_mongodb_ctl.sh"),
      File.join(gear_home, "mongodb-2.0", "#{gear_name}_ctl.sh"),
      Dir.glob(File.join(gear_home, ".env", ".uservars", "*")),
      Dir.glob(File.join(gear_home, ".env", "*")),
      Dir.glob(File.join(gear_home, "..", ".httpd.d", "#{uuid}_*.conf")),
      Dir.glob(File.join(gear_home, "..", ".httpd.d", "#{uuid}_*/*.conf"))
    ].flatten.sort { |i,j| i.length <=> j.length }.each do |entry|

      # Fix the entry itself and correct file name for below.
      entry = self.mongodb_xform_ent(entry) do |dentry|
        if File.exist?(entry) and not File.exist?(dentry)
          output+="Rename: #{entry} -> #{dentry}\n"
          File.rename(entry, dentry)
        end
      end

      # Fix symlink targets or file contents.  Do not edit files
      # through a symlink to avoid the risk of accidentally making
      # edits outside the gear.
      if File.symlink?(entry)
        self.mongodb_xform_ent(File.readlink(entry)) do |dstlink|
          output+="Fix Symlink: #{entry} -> #{dstlink}\n"
          File.unlink(entry)
          File.symlink(dstlink,entry)
          mcs_label = Util.get_mcs_level(uuid)
          output+="Fixing selinux MCS label: #{entry} -> system_u:object_r:libra_var_lib_t:#{mcs_label}"
          %x[ chcon -h -u system_u -r object_r -t libra_var_lib_t -l #{mcs_label} #{entry} ]
        end

      elsif File.file?(entry)
        File.open(entry, File::RDWR) do |f|
          self.mongodb_xform_ent(f.read) do |dstbuf|
            output+="File contents: #{entry}\n"
            f.seek(0)
            f.truncate(0)
            f.write(dstbuf)
          end
        end
      end

    end

    return output
  end

  # Note: This method must be reentrant.  Meaning it should be able to 
  # be called multiple times on the same gears.  Each time having failed 
  # at any point and continue to pick up where it left off or make
  # harmless changes the 2-n times around.
  def self.migrate(uuid, namespace, version)
    if version == "2.0.18"
      libra_home = '/var/lib/stickshift' #node_config.get_value('libra_dir')
      libra_server = get_config_value('BROKER_HOST')
      libra_domain = get_config_value('CLOUD_DOMAIN')
      gear_home = "#{libra_home}/#{uuid}"
      gear_name = Util.get_env_var_value(gear_home, "OPENSHIFT_GEAR_NAME")
      app_name = Util.get_env_var_value(gear_home, "OPENSHIFT_APP_NAME")
      gear_dir = "#{gear_home}/#{gear_name}"
      output = ''
      exitcode = 0

      if (File.exists?(gear_home) && !File.symlink?(gear_home))
        gear_type = Util.get_env_var_value(gear_home, "OPENSHIFT_GEAR_TYPE")
        cartridge_root_dir = "/usr/libexec/stickshift/cartridges"
        cartridge_dir = "#{cartridge_root_dir}/#{gear_type}"

        env_echos = []

        env_echos.each do |env_echo|
          echo_output, echo_exitcode = Util.execute_script(env_echo)
          output += echo_output
        end

        begin
          output+=self.migrate_mongodb_22(uuid, gear_home, gear_name)
        rescue => e
          output+="Exception caught in mongo migration:\n"
          output+="#{e}\n"
          exitcode=100
        end

      else
        exitcode = 127
        output += "Application not found to migrate: #{gear_home}\n"
      end
      return output, exitcode
    else
      return "Invalid version: #{version}", 255
    end
  end
end
