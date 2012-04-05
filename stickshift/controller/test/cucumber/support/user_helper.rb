require '/var/www/stickshift/broker/config/environment'

module UserHelper
  #
  # Obtain a unique username from S3.
  #
  #   reserved_usernames = A list of reserved names that may
  #     not be in the global store
  #
  def get_unique_username(reserved_usernames=[])
    result={}

    loop do
      # Generate a random username
      chars = ("1".."9").to_a
      namespace = "unit" + Array.new(8, '').collect{chars[rand(chars.size)]}.join
      login = "cucumber-test+#{namespace}@example.com"
      has_txt = !StickShift::DnsService.instance.namespace_available?(namespace)

      unless has_txt or reserved_usernames.index(login)
        result[:login] = login
        result[:namespace] = namespace
        break
      end
    end

    return result
  end

  def register_user(login, password)
    command = run("#{$user_register_script} -u #{login} -p #{password}") 
  
    pid, stdin, stdout, stderr = nil, nil, nil, nil
    Bundler.with_clean_env {
            pid, stdin, stdout, stderr = Open4::popen4(command)
            stdin.close
            ignored, status = Process::waitpid2 pid
            exitcode = status.exitstatus
        }
  end

end
World(UserHelper)