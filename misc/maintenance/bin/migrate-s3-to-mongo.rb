require 'rubygems'
require 'aws'
require 'aws/s3'
require 'mongo'
require 'cloud-sdk-controller'

# Configurable params
$config = {
  # S3 params
  :aws_key    => "AKIAITDQ37BWZ5CKAORA",
  :aws_secret => "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",
  :s3_bucket  => "libra_dev",

  # Mongo params
  :host       => "localhost",
  :port       => 27017,
  :user       => "libra",
  :password   => "momo",
  :db         => "openshift_broker_dev",
  :collection => "user"
}

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

def mongo_connect
  con = Mongo::Connection.new($config[:host], $config[:port])
  admin_db = con.db("admin")
  admin_db.authenticate($config[:user], $config[:password])
  $coll = con.db($config[:db]).collection($config[:collection])
end

def mongo_populate
  users = {}
  user_info = bucket.objects.with_prefix('user_info')

  user_info.each do |user_obj|
    if user_obj.key.end_with?('/user.json') && !user_obj.key.end_with?('/apps/user.json')
      # Get RH login user data
      user_name = File.basename(File.dirname(user_obj.key))
      user_data_str = user_obj.read
      next if not user_data_str
      user_data_str.gsub!(/\"\s*:/, "\" => ")
      user_data_str.gsub!(/null/, "\"\"")
      #puts user_data_str
      puts user_name
      user_data = eval(user_data_str)

      # update ssh keys
      user_data["ssh_keys"] = {} unless user_data["ssh_keys"]
      user_data["ssh_type"] = "ssh-rsa" if user_data["ssh_type"].to_s.strip.length == 0
      user_data["ssh_keys"][CloudUser::DEFAULT_SSH_KEY_NAME] = { "key" => user_data["ssh"], "type" => user_data["ssh_type"] }

      # Create user bson doc
      bson_doc = { 
              "_id"             => user_name,
              "uuid"            => user_data["uuid"],
              "rhlogin"         => user_data["rhlogin"],
              "namespace"       => user_data["namespace"],
              "ssh_keys"        => user_data["ssh_keys"],
              "max_gears"       => 5
            }
            
      bson_doc["system_ssh_keys"] = user_data["system_ssh_keys"] if user_data["system_ssh_keys"] 
      bson_doc["env_vars"] = user_data["env_vars"] if user_data["env_vars"]              
        
      # Get all apps for this RH login user
      app_prefix = "user_info/#{user_name}/apps/"
      app_info = bucket.objects.with_prefix(app_prefix)
      app_bson_doc = {}
      next if not app_info

      app_info.map do |app_obj|
        app_data_str = app_obj.read
        next if (not app_data_str) or app_data_str.empty?
        app_name = app_obj.key.gsub(app_prefix,'')[0..-6]
        #puts app_name
        app_data_str.gsub!(/\"\s*:/, "\" => ")
        app_data_str.gsub!(/null/, "\"\"")
        #puts app_data_str
        app_data = eval(app_data_str)

        # Migrate wsgi/rack to python/ruby
        app_data['framework'] = 'ruby-1.8' if app_data['framework'] == 'rack-1.1'
        app_data['framework'] = 'python-2.6' if app_data['framework'] == 'wsgi-3.2'
        
        # Create app bson doc
        embedded_carts = {}
        app_data["embedded"].each do |cart_name, cart_info|
          # FIXME: Hack to overcome mongo limitation, key name can't have '.' char
          cname = cart_name.gsub(Cloud::Sdk::MongoDataStore::DOT, 
                                 Cloud::Sdk::MongoDataStore::DOT_SUBSTITUTE)
          embedded_carts[cname] = cart_info
        end if app_data["embedded"]
        embedded_carts = nil if embedded_carts.empty?
        app_bson_doc[app_name] = \
                          {
                            "name"            => app_name,
                            "uuid"            => app_data["uuid"],
                            "framework"       => app_data["framework"],
                            "creation_time"   => app_data["creation_time"],
                            "server_identity" => app_data["server_identity"],
                            "embedded"        => embedded_carts,
                            "aliases"         => app_data["aliases"]
                          }
      end
      bson_doc["consumed_gears"] = app_bson_doc.length
      bson_doc["apps"] = app_bson_doc

      # Insert doc into the mongo collection
      $coll.insert(bson_doc)
    end
  end
end

mongo_connect
puts "User migration from S3 to Mongo datastore Started"
mongo_populate
puts "User migration from S3 to Mongo datastore Done!"
