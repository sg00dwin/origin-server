require 'parseconfig'
require 'aws'

# Force synchronous stdout
STDOUT.sync, STDERR.sync = true

# This will verify the Amazon SSL connection
Rightscale::HttpConnection.params[:ca_file] = "/etc/pki/tls/certs/ca-bundle.trust.crt"

def parse_amz_credentials
  begin
    config = ParseConfig.new(File.expand_path("~/.awscred"))
    return config.get_value("AWSAccessKeyId"), config.get_value("AWSSecretKey")
  rescue StandardError => e
    puts <<-eos
      Couldn't access credentials in ~/.awscred

      Please create a file with the following format:
        AWSAccessKeyId=<ACCESS_KEY>
        AWSSecretKey=<SECRET_KEY>
    eos
    raise "Error - no credentials"
  end
end

def aws_conn
  access_key, secret_key = parse_amz_credentials
  Aws::Ec2.new(access_key, secret_key, params = {:logger => Logger.new('/dev/null')})
end

def create_instance(conn, name)
  print "Creating new instance..."
  instance = conn.launch_instances(AMI, OPTIONS)[0][:aws_instance_id]
  puts "Done"

  # Small sleep to avoid
  sleep 2
 
  # Block until the instance is SSH available
  server = block_until_available(conn, instance)

  # Tag the instance
  conn.create_tag(instance, 'Name', name)

  return instance, server
end

def terminate(conn, instance)
  print "Terminating instance (#{instance})..."
  conn.terminate_instances([instance])
  puts "Done"
end

def reboot(conn, instance)
  print "Rebooting instance (#{instance})..."
  conn.reboot_instances([instance])
  puts "Done"

  # Block until the instance is SSH available
  block_until_available(conn, instance)
end

def register(conn, instance, name)
  print "Registering AMI based on instance (#{instance})..."
  image = conn.create_image(instance, name)

  (0..30) do
    break if get_image_value(conn, image, :aws_state) == 'available'
    puts "Image not available yet"
    sleep 60
  end

  unless get_image_value(conn, image, :aws_state) == 'available'
    exit_and_terminate(conn, instance, "AMI registration timed out")
  end

  puts "Done"
end

def get_value(conn, instance, key)
  conn.describe_instances([instance])[0][key]
end

def get_image_value(conn, image, key)
  conn.describe_images([image], 'machine')[0][key]
end

def ssh(server, cmd, timeout=60)
  puts "(ssh: server = #{server} / timeout = #{timeout} / cmd = #{cmd})"
  output = ""
  begin
    ssh_cmd = "#{SSH} root@#{server} '#{cmd}'"
    Timeout::timeout(timeout) { output = `#{ssh_cmd}`.chomp }
  rescue Timeout::Error
    puts "SSH command timed out"
  end
  puts "----------------------------\n#{output}\n----------------------------"
  return output
end

def scp(cmd, timeout=60)
  puts "(scp: timeout = #{timeout}) / cmd = #{cmd}"
  output = ""
  begin
    Timeout::timeout(timeout) { output = `#{SCP} #{cmd}` }
  rescue Timeout::Error
    puts "SCP command '#{cmd}' timed out"
  end
  puts "begin output ----------------------------\n#{output}\nend output ------------------------------\n"
  return output
end

def is_running?(conn, instance)
  get_value(conn, instance, :aws_state) == "running"
end

def can_ssh?(server)
  ssh(server, 'echo Success', 5).split[-1] == "Success"
end

def retry_block(conn, instance, retry_msg, max_retries = 15)
  (0..max_retries) do
    break if yield
    puts retry_msg + "... retrying"
    sleep 5
  end
 
  unless yield
    exit_and_terminate(conn, instance, "Operation timed out")
  end
end

def block_until_available(conn, instance)
  print "Waiting for instance to be available..."
  retry_block(conn, instance, "Instance isn't running yet") { is_running?(conn, instance)}
  server = get_value(conn, instance, :dns_name)
  retry_block(conn, instance, "SSH timed out") { can_ssh?(server)}
  puts "Done"

  return server
end

def send_verified_email(version, ami)
    msg = <<END_OF_MESSAGE
From: Jenkins <noreply@redhat.com>
To: Matt Hicks <mhicks@redhat.com>
Subject: Jenkins Build #{version} QE Ready

The build #{version} (AMI #{ami}) is ready for QE.
END_OF_MESSAGE

    Net::SMTP.start('localhost') do |smtp|
      smtp.send_message msg, "noreply@redhat.com", "libra-express@redhat.com"
    end
end

def fail_and_terminate(conn, instance, msg)
  conn.terminate_instances([instance])
  fail msg
end

def exit_and_terminate(conn, instance, msg)
  puts "EXITING - " + msg
  conn.terminate_instances([instance])
  exit 0
end

def setup_rsa_key
  unless File.exists?(RSA)
    print "Setting up RSA key..."
    libra_key = File.expand_path("../../misc/libra.pem", File.expand_path(__FILE__))
    FileUtils.cp(libra_key, RSA)
    FileUtils.chmod 0600, RSA
    puts "Done"
  end
end

def get_version(package)
  yum_output = `yum info #{package}`

  # Process the yum output to get a version
  version = yum_output.split("\n").collect do |line|
    line.split(":")[1].strip if line.start_with?("Version")
  end.compact[-1]

  # Process the yum output to get a release
  release = yum_output.split("\n").collect do |line|
    line.split(":")[1].strip if line.start_with?("Release")
  end.compact[-1]

  return "#{version}-#{release.split('.')[0]}"
end

def check_update
  yum_output = `yum check-update rhc-*`

  # For testing
  yum_output = <<-eos
Loaded plugins: product-id, security, subscription-manager
Updating Red Hat repositories.
Skipping security plugin, no data

rhc.noarch                  0.72.2-1.el6            li                          
rhc-common.noarch           0.72.1-2.el6            li                          
rhc-devenv.noarch           0.72.2-1.el6            li                          
rhc-node.noarch             0.72.3-1.el6            li                          
Obsoleting Packages
ipa-client.x86_64           2.0.0-23.el6            rhel-server-6-updates       
    ipa-client.x86_64       2.0-9.el6               @koji-override-0/$releasever
qpid-qmf.x86_64             0.10-6.el6              rhel-server-6-updates       
    qmf.x86_64              0.7.946106-13.el6       @qpid                       
ruby-qpid-qmf.x86_64        0.10-6.el6              rhel-server-6-updates       
    ruby-qmf.x86_64         0.7.946106-13.el6       @qpid     
eos

  packages = {}
  yum_output.split("\n").each do |line|
    if line.start_with?("Obsoleting")
      break
    elsif line.start_with?("rhc")
      pkg_name = line.split[0]
      version = line.split[1]
      packages[pkg_name] = version
    end
  end

  packages
end
