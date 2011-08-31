
require 'openshift-node/cgroup.rb'
require 'openshift-node/config.rb'

module Node
  def self.uuid_lookup(app_name)
    app_name = app_name.sub('-', '_')
    throw :app_not_found unless Dir.glob("/etc/httpd/conf.d/libra/????????????????????????????????_#{app_name}.conf")[0]
    conf_d_path = Dir.glob("/etc/httpd/conf.d/libra/????????????????????????????????_#{app_name}.conf")[0]
    basename = File.basename(conf_d_path)
    uuid = basename.split('_')[0]
  end


  # Read in values from ~/.resource_config and set them
  def self.sync(uuid)
    begin
      limits = Config.new(uuid)
    rescue Errno::EACCES => e
      $stderr.puts "Could not read resource config for #{uuid}:"
      $stderr.puts "  #{e.message}"
      return 4
    rescue ArgumentError => e
      $stderr.puts "Could not sync: #{e.message}"
      return 3
    end

    limits.resource_limits.params.each do |key, value|

      # Cgroups
      if key.start_with?('cgroup.')
        cg_key = key.sub('cgroup.', '')
        cg = Cgroup.new(uuid, cg_key)
        cg.cgroup = value
      end

      # pam

      # quota
      
      # tc
    end
  end
end
