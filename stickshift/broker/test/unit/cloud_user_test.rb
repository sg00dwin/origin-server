require 'test_helper'
require 'stickshift-controller'
require 'mocha'

module Rails
  def self.logger
    l = Mocha::Mock.new("logger")
    l.expects(:debug)
    l
  end
end

class CloudUserTest < ActiveSupport::TestCase
  test "validation of login" do
    invalid_chars = '"$^<>|%/;:,\*=~'
    invalid_chars.length.times do |i|
      user = CloudUser.new("test#{invalid_chars[i].chr}login", "ssh", "namespace")
      assert user.invalid?
      assert 107, user.errors[:login][0][:exit_code]
    end
    
    user = CloudUser.new("kraman@redhat.com", "ssh", "namespace")
    assert user.valid?
  end
  
  test "validation of ssh key" do
    invalid_chars = '"$^<>|%;:,\*~'
    invalid_chars.length.times do |i|
      user = CloudUser.new("kraman@redhat.com", "ssh#{invalid_chars[i].chr}key", "namespace")
      assert user.invalid?
      assert 108, user.errors[:ssh_keys][0][:exit_code]
    end
    
    user = CloudUser.new("kraman@redhat.com", "ABCdef012+/=", "namespace")
    assert user.valid?
  end
  
  test "validation of namespace" do
    invalid_chars = '"$^<>|%;:,\*~='
    invalid_chars.length.times do |i|
      user = CloudUser.new("kraman@redhat.com", "ssh", "name#{invalid_chars[i].chr}space")
      assert user.invalid?
      assert 106, user.errors[:namespace][0][:exit_code]
    end
    
    user = CloudUser.new("kraman@redhat.com", "ABCdef012+/=", "Namespace01")
    assert user.valid?
  end

  test "create a new user" do
    ssh = "AAAAB3NzaC1yc2EAAAABIwAAAQEAvzdpZ/3+PUi3SkYQc3j8v5W8+PUNqWe7p3xd9r1y4j60IIuCS4aaVqorVPhwrOCPD5W70aeLM/B3oO3QaBw0FJYfYBWvX3oi+FjccuzSmMoyaYweXCDWxyPi6arBqpsSf3e8YQTEkL7fwOQdaZWtW7QHkiDCfcB/LIUZCiaArm2taIXPvaoz/hhHnqB2s3W/zVP2Jf5OkQHsVOTxYr/Hb+/gV3Zrjy+tE9+z2ivL+2M0iTIoSVsUcz0d4g4XpgM8eG9boq1YGzeEhHe1BeliHmAByD8PwU74tOpdpzDnuKf8E9Gnwhsp2yqwUUkkBUoVcv1LXtimkEyIl0dSeRRcMw=="
    namespace = "kraman.stickshift.net"
    login = "kraman@redhat.com"
    user = CloudUser.new(login, ssh, namespace)
     
    observer_seq = sequence("observer_seq")
    
    CloudUser.expects(:find).returns(nil)
    dns = mock("DnsService")
    StickShift::DnsService.expects(:instance).returns(dns)
    dns.expects(:namespace_available?).with(namespace).returns(true)
         
    CloudUser.expects(:notify_observers).with(:before_cloud_user_create, user).in_sequence(observer_seq).at_least_once
    CloudUser.expects(:notify_observers).with(:cloud_user_create_success, user).in_sequence(observer_seq).at_least_once
    CloudUser.expects(:notify_observers).with(:after_cloud_user_create, user).in_sequence(observer_seq).at_least_once

    ds = mock("DataStore")
    StickShift::DataStore.expects(:instance).returns(ds)
    ds.expects(:create)
    
    dns.expects(:register_namespace).with(namespace).at_least_once
    dns.expects(:publish).at_least_once
    dns.expects(:close).at_least_once
    
    user.save
  end
  
  test "create user fails if user already exists" do
    ssh = "AAAAB3NzaC1yc2EAAAABIwAAAQEAvzdpZ/3+PUi3SkYQc3j8v5W8+PUNqWe7p3xd9r1y4j60IIuCS4aaVqorVPhwrOCPD5W70aeLM/B3oO3QaBw0FJYfYBWvX3oi+FjccuzSmMoyaYweXCDWxyPi6arBqpsSf3e8YQTEkL7fwOQdaZWtW7QHkiDCfcB/LIUZCiaArm2taIXPvaoz/hhHnqB2s3W/zVP2Jf5OkQHsVOTxYr/Hb+/gV3Zrjy+tE9+z2ivL+2M0iTIoSVsUcz0d4g4XpgM8eG9boq1YGzeEhHe1BeliHmAByD8PwU74tOpdpzDnuKf8E9Gnwhsp2yqwUUkkBUoVcv1LXtimkEyIl0dSeRRcMw=="
    namespace = "kraman.stickshift.net"
    login = "kraman@redhat.com"
    user = CloudUser.new(login, ssh, namespace)
     
    observer_seq = sequence("observer_seq")
    
    CloudUser.expects(:find).returns(user)
    StickShift::DnsService.instance.class.any_instance.expects(:namespace_available?).with(namespace).returns(true).never
         
    CloudUser.expects(:notify_observers).with(:before_cloud_user_create, user).in_sequence(observer_seq).at_least_once
    CloudUser.expects(:notify_observers).with(:after_cloud_user_create, user).in_sequence(observer_seq).at_least_once
    
    StickShift::DnsService.instance.class.any_instance.expects(:register_namespace).never
    StickShift::DnsService.instance.class.any_instance.expects(:publish).never
    StickShift::DnsService.instance.class.any_instance.expects(:close).once
    
    begin
      user.save
    rescue StickShift::UserException => e
      assert true
    else
      assert false
    end
  end

  test "create user fails if domain already exists" do
    ssh = "AAAAB3NzaC1yc2EAAAABIwAAAQEAvzdpZ/3+PUi3SkYQc3j8v5W8+PUNqWe7p3xd9r1y4j60IIuCS4aaVqorVPhwrOCPD5W70aeLM/B3oO3QaBw0FJYfYBWvX3oi+FjccuzSmMoyaYweXCDWxyPi6arBqpsSf3e8YQTEkL7fwOQdaZWtW7QHkiDCfcB/LIUZCiaArm2taIXPvaoz/hhHnqB2s3W/zVP2Jf5OkQHsVOTxYr/Hb+/gV3Zrjy+tE9+z2ivL+2M0iTIoSVsUcz0d4g4XpgM8eG9boq1YGzeEhHe1BeliHmAByD8PwU74tOpdpzDnuKf8E9Gnwhsp2yqwUUkkBUoVcv1LXtimkEyIl0dSeRRcMw=="
    namespace = "kraman.stickshift.net"
    login = "kraman@redhat.com"
    user = CloudUser.new(login, ssh, namespace)
     
    observer_seq = sequence("observer_seq")
    
    CloudUser.expects(:find).returns(nil)
    StickShift::DnsService.instance.class.any_instance.expects(:namespace_available?).with(namespace).returns(false)
         
    CloudUser.expects(:notify_observers).with(:before_cloud_user_create, user).in_sequence(observer_seq).at_least_once
    CloudUser.expects(:notify_observers).with(:after_cloud_user_create, user).in_sequence(observer_seq).at_least_once
    
    StickShift::DnsService.instance.class.any_instance.expects(:register_namespace).never
    StickShift::DnsService.instance.class.any_instance.expects(:publish).never
    StickShift::DnsService.instance.class.any_instance.expects(:close).once
    
    begin
      user.save
    rescue StickShift::UserException => e
      assert true
    else
      assert false
    end
  end

  test "system ssh key" do
    ssh = "AAAAB3NzaC1yc2EAAAABIwAAAQEAvzdpZ/3+PUi3SkYQc3j8v5W8+PUNqWe7p3xd9r1y4j60IIuCS4aaVqorVPhwrOCPD5W70aeLM/B3oO3QaBw0FJYfYBWvX3oi+FjccuzSmMoyaYweXCDWxyPi6arBqpsSf3e8YQTEkL7fwOQdaZWtW7QHkiDCfcB/LIUZCiaArm2taIXPvaoz/hhHnqB2s3W/zVP2Jf5OkQHsVOTxYr/Hb+/gV3Zrjy+tE9+z2ivL+2M0iTIoSVsUcz0d4g4XpgM8eG9boq1YGzeEhHe1BeliHmAByD8PwU74tOpdpzDnuKf8E9Gnwhsp2yqwUUkkBUoVcv1LXtimkEyIl0dSeRRcMw=="
    namespace = "kraman.stickshift.net"
    login = "kraman@redhat.com"
    apps = [mock("app1"), mock("app2")]
    apps.each {|app| app.expects(:add_authorized_ssh_key).returns(ResultIO.new).once}
    apps.each {|app| app.expects(:name).once}    
    
    user = CloudUser.new(login, ssh, namespace)
    user.expects(:save).once
    user.expects(:applications).returns(apps)
    
    user.add_system_ssh_key("app_name", "key")
    assert user.system_ssh_keys["app_name"].nil? == false
    
    apps = [mock("app1"), mock("app2")]
    apps.each {|app| app.expects(:remove_authorized_ssh_key).returns(ResultIO.new).once}
    apps.each {|app| app.expects(:name).once}
    user.expects(:save).once
    user.expects(:applications).returns(apps)
    
    user.remove_system_ssh_key("app_name")
    assert user.system_ssh_keys["app_name"].nil?    
  end
  
  test "environment variable" do
    ssh = "AAAAB3NzaC1yc2EAAAABIwAAAQEAvzdpZ/3+PUi3SkYQc3j8v5W8+PUNqWe7p3xd9r1y4j60IIuCS4aaVqorVPhwrOCPD5W70aeLM/B3oO3QaBw0FJYfYBWvX3oi+FjccuzSmMoyaYweXCDWxyPi6arBqpsSf3e8YQTEkL7fwOQdaZWtW7QHkiDCfcB/LIUZCiaArm2taIXPvaoz/hhHnqB2s3W/zVP2Jf5OkQHsVOTxYr/Hb+/gV3Zrjy+tE9+z2ivL+2M0iTIoSVsUcz0d4g4XpgM8eG9boq1YGzeEhHe1BeliHmAByD8PwU74tOpdpzDnuKf8E9Gnwhsp2yqwUUkkBUoVcv1LXtimkEyIl0dSeRRcMw=="
    namespace = "kraman.stickshift.net"
    login = "kraman@redhat.com"
    apps = [mock("app1"), mock("app2")]
    apps.each {|app| app.expects(:add_env_var).returns(ResultIO.new).once}
    apps.each {|app| app.expects(:name).once}    
    
    user = CloudUser.new(login, ssh, namespace)
    user.expects(:save).once
    user.expects(:applications).returns(apps)
    
    user.add_env_var("key", "value")
    assert user.env_vars["key"] == "value"
    
    apps = [mock("app1"), mock("app2")]
    apps.each {|app| app.expects(:remove_env_var).returns(ResultIO.new).once}
    apps.each {|app| app.expects(:name).once}
    user.expects(:save).once
    user.expects(:applications).returns(apps)
    
    user.remove_env_var("key")
    assert user.env_vars["key"].nil?
  end
  
  test "user ssh keys" do
    ssh = "AAAAB3NzaC1yc2EAAAABIwAAAQEAvzdpZ/3+PUi3SkYQc3j8v5W8+PUNqWe7p3xd9r1y4j60IIuCS4aaVqorVPhwrOCPD5W70aeLM/B3oO3QaBw0FJYfYBWvX3oi+FjccuzSmMoyaYweXCDWxyPi6arBqpsSf3e8YQTEkL7fwOQdaZWtW7QHkiDCfcB/LIUZCiaArm2taIXPvaoz/hhHnqB2s3W/zVP2Jf5OkQHsVOTxYr/Hb+/gV3Zrjy+tE9+z2ivL+2M0iTIoSVsUcz0d4g4XpgM8eG9boq1YGzeEhHe1BeliHmAByD8PwU74tOpdpzDnuKf8E9Gnwhsp2yqwUUkkBUoVcv1LXtimkEyIl0dSeRRcMw=="
    namespace = "kraman.stickshift.net"
    login = "kraman@redhat.com"
    apps = [mock("app1"), mock("app2")]
    apps.each {|app| app.expects(:add_authorized_ssh_key).returns(ResultIO.new).once}
    apps.each {|app| app.expects(:name).once}    
    
    user = CloudUser.new(login, ssh, namespace)
    user.expects(:save).once
    user.expects(:applications).returns(apps)
    
    user.add_ssh_key("key_name", "key")
    assert user.ssh_keys["key_name"].nil? == false
    
    apps = [mock("app1"), mock("app2")]
    apps.each {|app| app.expects(:remove_authorized_ssh_key).returns(ResultIO.new).once}
    apps.each {|app| app.expects(:name).once}
    user.expects(:save).once
    user.expects(:applications).returns(apps)
    
    user.remove_ssh_key("key_name")
    assert user.ssh_keys["key_name"].nil?
  end
  
  test "updating namespace" do
    #first create a user
    ssh = "AAAAB3NzaC1yc2EAAAABIwAAAQEAvzdpZ/3+PUi3SkYQc3j8v5W8+PUNqWe7p3xd9r1y4j60IIuCS4aaVqorVPhwrOCPD5W70aeLM/B3oO3QaBw0FJYfYBWvX3oi+FjccuzSmMoyaYweXCDWxyPi6arBqpsSf3e8YQTEkL7fwOQdaZWtW7QHkiDCfcB/LIUZCiaArm2taIXPvaoz/hhHnqB2s3W/zVP2Jf5OkQHsVOTxYr/Hb+/gV3Zrjy+tE9+z2ivL+2M0iTIoSVsUcz0d4g4XpgM8eG9boq1YGzeEhHe1BeliHmAByD8PwU74tOpdpzDnuKf8E9Gnwhsp2yqwUUkkBUoVcv1LXtimkEyIl0dSeRRcMw=="
    namespace = "kraman.stickshift.net"
    login = "kraman@redhat.com"
    user = CloudUser.new(login, ssh, namespace)
     
    CloudUser.expects(:find).returns(nil)
    dns = mock("DnsService")
    StickShift::DnsService.expects(:instance).returns(dns)

    dns.expects(:namespace_available?).with(namespace).returns(true)
    dns.expects(:register_namespace).with(namespace).at_least_once
    dns.expects(:publish).at_least_once
    dns.expects(:close).at_least_once
    user.save
    Mocha::Mockery.instance.stubba.unstub_all

    #update namespace
    app_container = mock()
    app_container.expects(:get_public_hostname).returns("foo.bar").at_least_once
    apps = [mock("app1"), mock("app2")]
    apps.each {|app|
      app.expects(:update_namespace).once.returns(ResultIO.new)
      app.expects(:embedded).returns({})
      app.expects(:container).returns(app_container)
      app.expects(:save)      
    }
    apps[0].expects(:name).at_least_once.returns("app1")
    apps[1].expects(:name).at_least_once.returns("app2")
    user.expects(:applications).returns(apps).at_least_once

    observer_seq = sequence("observer_seq")
    CloudUser.expects(:notify_observers).with(:before_namespace_update, user).in_sequence(observer_seq).at_least_once
    CloudUser.expects(:notify_observers).with(:namespace_update_success, user).in_sequence(observer_seq).at_least_once
    CloudUser.expects(:notify_observers).with(:after_namespace_update, user).in_sequence(observer_seq).at_least_once
    
    new_namespace = "kraman.stickshift1.net"
    dns = mock("DnsService")
    StickShift::DnsService.expects(:instance).returns(dns)
    dns.expects(:namespace_available?).with(new_namespace).returns(true)
    dns.expects(:deregister_namespace).with(namespace).once
    dns.expects(:register_namespace).with(new_namespace).once
    dns.expects(:publish).once
    dns.expects(:close).once
    
    dns.expects(:deregister_application).with("app1", namespace).once
    dns.expects(:deregister_application).with("app2", namespace).once
    dns.expects(:register_application).with("app1", new_namespace, "foo.bar").once
    dns.expects(:register_application).with("app2", new_namespace, "foo.bar").once
    CloudUser.excludes_attributes.push :mocha
    
    user.update_namespace(new_namespace)
  end
  
  def teardown
    Mocha::Mockery.instance.stubba.unstub_all
  end
end
