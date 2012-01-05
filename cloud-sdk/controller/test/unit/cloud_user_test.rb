require 'cloud-sdk-controller'
require 'test_helper'
require 'mocha'

module Rails
  def self.logger
    l = Mocha::Mock.new("logger")
    l.expects(:debug)
    l
  end
end

class CloudUserTest < ActiveSupport::TestCase
  test "validation of rhlogin" do
    invalid_chars = '"$^<>|%/;:,\*=~'
    invalid_chars.length.times do |i|
      user = CloudUser.new("test#{invalid_chars[i].chr}login", "ssh", "namespace")
      assert user.invalid?
      assert 107, user.errors[:rhlogin][0][:exit_code]
    end
    
    user = CloudUser.new("kraman@redhat.com", "ssh", "namespace")
    assert user.valid?
  end
  
  test "validation of ssh key" do
    invalid_chars = '"$^<>|%;:,\*~'
    invalid_chars.length.times do |i|
      user = CloudUser.new("kraman@redhat.com", "ssh#{invalid_chars[i].chr}key", "namespace")
      assert user.invalid?
      assert 108, user.errors[:ssh][0][:exit_code]
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
    namespace = "kraman.cloudsdk.net"
    rhlogin = "kraman@redhat.com"
    user = CloudUser.new(rhlogin, ssh, namespace)
     
    observer_seq = sequence("observer_seq")
    
    CloudUser.expects(:find).returns(nil)
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:namespace_available?).with(namespace).returns(true)
         
    CloudUser.expects(:notify_observers).with(:before_cloud_user_create, user).in_sequence(observer_seq).at_least_once
    CloudUser.expects(:notify_observers).with(:cloud_user_create_success, user).in_sequence(observer_seq).at_least_once
    CloudUser.expects(:notify_observers).with(:after_cloud_user_create, user).in_sequence(observer_seq).at_least_once
    Cloud::Sdk::DataStore.instance.class.any_instance.expects(:save)
    
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:register_namespace).with(namespace).at_least_once
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:publish).at_least_once
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:close).at_least_once
    
    user.save
  end
  
  test "create user fails if user already exists" do
    ssh = "AAAAB3NzaC1yc2EAAAABIwAAAQEAvzdpZ/3+PUi3SkYQc3j8v5W8+PUNqWe7p3xd9r1y4j60IIuCS4aaVqorVPhwrOCPD5W70aeLM/B3oO3QaBw0FJYfYBWvX3oi+FjccuzSmMoyaYweXCDWxyPi6arBqpsSf3e8YQTEkL7fwOQdaZWtW7QHkiDCfcB/LIUZCiaArm2taIXPvaoz/hhHnqB2s3W/zVP2Jf5OkQHsVOTxYr/Hb+/gV3Zrjy+tE9+z2ivL+2M0iTIoSVsUcz0d4g4XpgM8eG9boq1YGzeEhHe1BeliHmAByD8PwU74tOpdpzDnuKf8E9Gnwhsp2yqwUUkkBUoVcv1LXtimkEyIl0dSeRRcMw=="
    namespace = "kraman.cloudsdk.net"
    rhlogin = "kraman@redhat.com"
    user = CloudUser.new(rhlogin, ssh, namespace)
     
    observer_seq = sequence("observer_seq")
    
    CloudUser.expects(:find).returns(true)
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:namespace_available?).with(namespace).returns(true).never
         
    CloudUser.expects(:notify_observers).with(:before_cloud_user_create, user).in_sequence(observer_seq).at_least_once
    CloudUser.expects(:notify_observers).with(:after_cloud_user_create, user).in_sequence(observer_seq).at_least_once
    
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:register_namespace).never
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:publish).never
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:close).once
    
    begin
      user.save
    rescue Cloud::Sdk::UserException => e
      assert true
    else
      assert false
    end
  end

  test "create user fails if domain already exists" do
    ssh = "AAAAB3NzaC1yc2EAAAABIwAAAQEAvzdpZ/3+PUi3SkYQc3j8v5W8+PUNqWe7p3xd9r1y4j60IIuCS4aaVqorVPhwrOCPD5W70aeLM/B3oO3QaBw0FJYfYBWvX3oi+FjccuzSmMoyaYweXCDWxyPi6arBqpsSf3e8YQTEkL7fwOQdaZWtW7QHkiDCfcB/LIUZCiaArm2taIXPvaoz/hhHnqB2s3W/zVP2Jf5OkQHsVOTxYr/Hb+/gV3Zrjy+tE9+z2ivL+2M0iTIoSVsUcz0d4g4XpgM8eG9boq1YGzeEhHe1BeliHmAByD8PwU74tOpdpzDnuKf8E9Gnwhsp2yqwUUkkBUoVcv1LXtimkEyIl0dSeRRcMw=="
    namespace = "kraman.cloudsdk.net"
    rhlogin = "kraman@redhat.com"
    user = CloudUser.new(rhlogin, ssh, namespace)
     
    observer_seq = sequence("observer_seq")
    
    CloudUser.expects(:find).returns(nil)
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:namespace_available?).with(namespace).returns(false)
         
    CloudUser.expects(:notify_observers).with(:before_cloud_user_create, user).in_sequence(observer_seq).at_least_once
    CloudUser.expects(:notify_observers).with(:after_cloud_user_create, user).in_sequence(observer_seq).at_least_once
    
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:register_namespace).never
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:publish).never
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:close).once
    
    begin
      user.save
    rescue Cloud::Sdk::UserException => e
      assert true
    else
      assert false
    end
  end

  
  test "adding secondary ssh key" do
  end
  
  test "removing secondary ssh key" do
  end
  
  test "adding system ssh key" do
  end
  
  test "removing system ssh key" do
  end
  
  test "adding environment variable" do
  end
  
  test "removing environment variable" do
  end
  
  test "creating a new user" do
  end
  
  test "deleting a user" do
  end
  
  test "updating namespace" do
  end
  
  test "updating namespace and ssh when ssh update fails" do
  end
  
  def teardown
    Mocha::Mockery.instance.stubba.unstub_all
  end
end