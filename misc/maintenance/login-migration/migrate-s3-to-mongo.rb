require 'rubygems'
require 'aws'
require 'aws/s3'
require 'mongo'
#require 'bson_ext'

$config = {
  :aws_key => "AKIAITDQ37BWZ5CKAORA",
  :aws_secret => "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",
  :s3_bucket => "libra_dev",

  :host => "localhost",
  :port => "27017",
  :database_name => "openshift",
  :collection_name => "test2"
}
#$db = nil
#$coll = nil 

def s3
  # Setup the global access configuration
  AWS.config(
    :access_key_id => $config[:aws_key],
    :secret_access_key => $config[:aws_secret],
    :ssl_ca_file => "/etc/pki/tls/certs/ca-bundle.trust.crt"
  )

  # Return the AMZ connection
  AWS::S3.new
end

def bucket
  s3.buckets[$config[:s3_bucket]]
end

def mongo_populate
  users = {}
  user_info = bucket.objects.with_prefix('user_info')

  user_info.each do |user_obj|
    if user_obj.key =~ /\/user.json$/
      # Get RH login user data
      user_name = File.basename(File.dirname(user_obj.key))
      user_data_str = user_obj.read
      user_data_str.gsub!(/\"\s*:/, "\" =>")
      #puts user_data_str
      puts user_name
      user_data = eval(user_data_str)

      # Create user bson doc
      user_ssh_keys = []
      if user_data["ssh_keys"] and user_data["ssh_keys"].kind_of?(Hash)
        user_data["ssh_keys"].each do |key_tag, key|
          user_ssh_keys.push({ key_tag => key })
        end
      end
      system_ssh_keys = []
      if user_data["system_ssh_keys"] and user_data["system_ssh_keys"].kind_of?(Hash)
        user_data["system_ssh_keys"].each do |name, key|
          system_ssh_keys.push({ name => key })
        end
      end
      env_vars = []
      if user_data["env_vars"] and user_data["env_vars"].kind_of?(Hash)
        user_data["env_vars"].each do |name, value|
          env_vars.push({ name => value })
        end
      end
      bson_doc = { 
              "_id"  => user_name,
              "uuid" => user_data["uuid"],
              "rhlogin" => user_data["rhlogin"],
              "namespace" => user_data["namespace"],
              "ssh" => user_data["ssh"],
              "ssh_keys" => user_ssh_keys,
              "system_ssh_keys" => system_ssh_keys,
              "env_vars" => env_vars
            }              
        
      # Get all apps for this RH login user
      app_prefix = "user_info/#{user_name}/apps/"
      app_info = bucket.objects.with_prefix(app_prefix)
      app_bson_doc = []
      app_info.map do |app_obj|
        # app_name = app_obj.key.gsub(app_prefix,'')[0..-6]
        app_data_str = app_obj.read
        app_data_str.gsub!(/\"\s*:/, "\" =>")
        #puts app_data_str
        app_data = eval(app_data_str)
        
        # Create app bson doc
        embedded_carts = []
        if app_data["embedded"] and app_data["embedded"].kind_of?(Hash)
          app_data["embedded"].each do |cart_name, cart_info|
            # FIXME: Temporary hack to overcome mongo limitation: key name can't have '.' char
            cname = cart_name.gsub(/\./, "(dot)")
            embedded_carts.push({ cname => cart_info })
          end
        end
        app_bson_doc.push({
                            "name" => app_data["name"],
                            "uuid" => app_data["uuid"],
                            "framework" => app_data["framework"],
                            "creation_time" => app_data["creation_time"],
                            "server_identity" => app_data["server_identity"],
                            "embedded"        => embedded_carts,
                            "aliases"         => app_data["aliases"]
                          })
      end
      bson_doc["apps"] = app_bson_doc

      # Insert doc into the mongo collection
      $coll.insert(bson_doc)
    end
  end
end

def mongo_connect
  $db = Mongo::Connection.new($config[:host], $config[:port]).db($config[:database_name])
  $coll = $db.collection($config[:collection_name])
end

def mongo_close
  
end

mongo_connect
mongo_populate
mongo_close
