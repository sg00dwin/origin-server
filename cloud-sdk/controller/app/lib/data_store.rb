require 'aws'

class DataStore
  def self.find(obj_type, user_id, id)
    print "DataStore.find(#{obj_type}, #{user_id}, #{id})\n\n"
    case obj_type
    when "CloudUser"
      get_user_s3(id)
    when "Application"
      get_app_s3(user_id,id)
    end
  end
  
  def self.find_all(obj_type, user_id)
    print "DataStore.find_all(#{obj_type}, #{user_id})\n\n"
    case obj_type
    when "CloudUser"
      get_user_s3(id)
    when "Application"
      get_user_apps_s3(user_id)
    end
  end
  
  def self.save(obj_type, user_id, id, serialized_obj)
    print "DataStore.save(#{obj_type}, #{user_id}, #{id}, #{serialized_obj})\n\n"    
  end
  
  def self.delete(obj_type, user_id, id)
    print "DataStore.delete(#{obj_type}, #{user_id}, #{id})\n\n"        
  end
  
  private
  
  def self.s3
    # Setup the global access configuration
    AWS.config(
      :access_key_id => Rails.application.config.cdk[:aws_key],
      :secret_access_key => Rails.application.config.cdk[:aws_secret],
      :ssl_ca_file => "/etc/pki/tls/certs/ca-bundle.trust.crt"
    )

    # Return the AMZ connection
    AWS::S3.new
  end

  def self.bucket
    s3.buckets[Rails.application.config.cdk[:s3_bucket]]
  end
  
  #
  # Returns all the user S3 JSON objects
  #
  def self.get_users_s3
    users = {}
    bucket.objects.with_prefix('user_info').each do |user_obj|
      users[user_obj.key.gsub("user_info/")[0..-6]] = user_obj.read
    end
    users
  end

  #
  # Returns the S3 user json object
  #
  def self.get_user_s3(rhlogin)
    {rhlogin => bucket.objects["user_info/#{rhlogin}/user.json"].read}
  end

  def self.get_user_apps_s3(rhlogin)
    apps = {}
    app_prefix = "user_info/#{rhlogin}/apps/"
    bucket.objects.with_prefix(app_prefix).map do |app_obj|
      apps[app_obj.key.gsub(app_prefix,'')[0..-6]] = app_obj.read
    end
    apps
  end

  #
  # Returns the application S3 json object
  #
  def self.get_app_s3(rhlogin, app_name)
    {app_name => bucket.objects["user_info/#{rhlogin}/apps/#{app_name}.json"].read}
  end
  
  #
  # Updates the S3 cache of the app
  #
  def self.update_app(app)
    json = app.to_json
    get_app_s3(app.user.rhlogin, app.name).write(json)
  end

  #
  # Delete an S3 cache of an app
  #
  def self.delete_app(app)
    result = get_app_s3(app.user.rhlogin, app.name)
    result.delete if result.exists?
  end
end