require 'rubygems'
require File.dirname(__FILE__) + "/migrate-util"

module OpenShiftMigration
  module FrontendHttpServerMigration

    def self.migrate(container_uuid, container_name, namespace)
      output = ""

      # Consider getting these from configuration
      http_conf_dir = "/etc/httpd/conf.d/openshift"
      cartridge_root_dir = "/usr/libexec/openshift/cartridges"
      libra_home = '/var/lib/openshift'

      gear_home = File.join(libra_home, container_uuid)

      mcs_level = Util.get_mcs_level(container_uuid)

      token = "#{container_uuid}_#{namespace}_#{container_name}"
      cfg_dir = File.join(http_conf_dir, token)
      cfg_file = File.join(http_conf_dir, token + ".conf")
      routes_file = File.join(cfg_dir,"routes.json")

      call_args = "--with-container-uuid #{container_uuid} --with-container-name #{container_name} --with-namespace #{namespace}"

      if File.exists?(cfg_file)
        server_config = File.read(cfg_file)

        if File.exists?(cfg_dir)
          Dir.glob(File.join(cfg_dir, "*.conf")).sort { |a,b| b<=>a }.each do |fn|
            server_config << "\n"
            server_config << File.read(fn)
          end
        end

        server_config << "\n"
        server_config << File.read(cfg_file)
        server_config << "\n"        

        o, r = Util.execute_script("oo-frontend-create #{call_args} 2>&1")
        output << o
        if r != 0
          return output, r
        end

        server_config.each_line do |l|
          clean_line = l.sub(/\#.*$/).strip

          connections = []
          
          case clean_line
          when /Alias.*restorer.php/
            o, r = Util.execute_script("oo-frontend-idle #{call_args} 2>&1")
            output << o
            if r != 0
              output << "ERROR: failed to re-idle the gear."
              return output, r
            end
          when /ServerAlias (.*)/
            new_alias=$1
            o, r = Util.execute_script("oo-add-alias #{call_args} --with-alias-name #{new_alias}")
            if r != 0
              output << "ERROR: Failed to add alias from: #{clean_line}"
              return output, r
            end
          end
        end

        # Its madness trying to parse the collection of Alias,
        # ProxyPass and RewriteRule stanzas.  Re-run the cartridge
        # deploy-httpd-proxy hooks.  The proper order appears to be:
        # 1. Framework + Embedded
        # 3. HAProxy  (can overwrite anything above)
        Dir.glob(File.join(gear_home, '*')).map { |d|
          File.basename(d)
        }.select { |c|
          not c.start_with?("haproxy-")
        }.map { |f|
          File.join(cartridge_root_dir,f,"info/hooks/remove-httpd-proxy")
        }.select { |h| 
          File.exists?(h)
        }.each do |hook|
          o, r = Util.execute_script("#{hook} #{container_name} #{namespace} #{container_uuid}")
          if r != 0
            o << "ERROR: Failed to execute #{hook} #{container_name} #{namespace} #{container_uuid}"
            return output, r
          end
        end

        Dir.glob(File.join(gear_home, 'haproxy-*')).map { |d|
          File.basename(d)
        }.map { |f|
          File.join(cartridge_root_dir,f,"info/hooks/remove-httpd-proxy")
        }.select { |h|
           File.exists?(h)
        }.each do |hook|
          o, r = Util.execute_script("#{hook} #{container_name} #{namespace} #{container_uuid}")
          if r != 0
            o << "ERROR: Failed to execute #{hook} #{container_name} #{namespace} #{container_uuid}"
            return output, r
          end
        end

        # Disable the old config, will be deleted later
        begin
          File.rename(cfg_file, cfg_file + ".migrated")
          File.rename(cfg_dir, cfg_dir + ".migrated")

          # Gracefully restart httpd to finish switching the gear over.
          o, r =Util.execute_script("/usr/sbin/oo-httpd-singular graceful")
          if r != 0
            o << "ERROR: Failed to reload httpd"
          end
          output += "DONE: #{token}.migrated #{token}.migrated"
        rescue => e
          output << "ERROR: Encountered an error moving old configs."
          return output, 127
        end
      end

      return output, 0
    end
    
  end
end
