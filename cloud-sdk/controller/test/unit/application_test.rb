require 'test_helper'
require 'cloud-sdk-controller'
require 'mocha'

module Rails
  def self.logger
    l = Mocha::Mock.new("logger")
    l.expects(:debug)
    l
  end
end

class ApplicationTest < ActiveSupport::TestCase

  test "create" do
    observer_seq = sequence("observer_seq")
    container = mock("container")
    container.expects(:id).returns("server1")
    container.expects(:create).returns(ResultIO.new)
    
    user = mock("user")
    user.expects(:rhlogin).returns("kraman@redhat.com")
    Application.expects(:notify_observers).with(:before_application_create, anything).in_sequence(observer_seq).once
    Application.expects(:notify_observers).with(:after_application_create, anything).in_sequence(observer_seq).once
    Cloud::Sdk::ApplicationContainerProxy.expects(:find_available).returns(container)
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    
    application.create
  end
  
  test "destroy" do
    observer_seq = sequence("observer_seq")
    container = mock("container")
    container.expects(:destroy).returns(ResultIO.new)
    
    user = mock("user")
    Application.expects(:notify_observers).with(:before_application_destroy, anything).in_sequence(observer_seq).once
    Application.expects(:notify_observers).with(:after_application_destroy, anything).in_sequence(observer_seq).once
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    application.container = container
    
    application.destroy
  end
  
  test "configure_dependencies" do    
    user = mock("user")    
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    
    observer_seq = sequence("observer_seq")
    Application.expects(:notify_observers).with(:before_application_configure, anything).in_sequence(observer_seq).once
    Application.expects(:notify_observers).with(:after_application_configure, anything).in_sequence(observer_seq).once
    container = mock("container")
    container.expects(:preconfigure_cartridge).returns(ResultIO.new)
    container.expects(:configure_cartridge).returns(ResultIO.new)
    application.expects(:process_cartridge_commands).returns(ResultIO.new)
    
    application.container = container
    application.configure_dependencies
  end
  
  test "deconfigure_dependencies" do
    user = mock("user")    
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    
    observer_seq = sequence("observer_seq")
    Application.expects(:notify_observers).with(:before_application_deconfigure, anything).in_sequence(observer_seq).once
    Application.expects(:notify_observers).with(:after_application_deconfigure, anything).in_sequence(observer_seq).once
    container = mock("container")
    container.expects(:deconfigure_cartridge).returns(ResultIO.new)
    application.expects(:process_cartridge_commands).returns(ResultIO.new)
    
    application.container = container
    application.deconfigure_dependencies
  end
  
  test "create_dns" do
    user = mock("user")    
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    
    observer_seq = sequence("observer_seq")
    Application.expects(:notify_observers).with(:before_create_dns, anything).in_sequence(observer_seq).once
    Application.expects(:notify_observers).with(:after_create_dns, anything).in_sequence(observer_seq).once
    
    container = mock("container")
    container.expects(:get_public_hostname).returns("foo.bar")
    user.expects(:namespace).returns("kraman")    
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:register_application).once
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:publish).once
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:close).once    

    application.container = container
    application.create_dns
  end

  test "destroy_dns" do
    user = mock("user")    
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    
    observer_seq = sequence("observer_seq")
    Application.expects(:notify_observers).with(:before_destroy_dns, anything).in_sequence(observer_seq).once
    Application.expects(:notify_observers).with(:after_destroy_dns, anything).in_sequence(observer_seq).once
    
    container = mock("container")
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:deregister_application).once
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:publish).once
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:close).once    
    user.expects(:namespace).returns("kraman")    

    application.container = container
    application.destroy_dns
  end
  
  test "recreate_dns" do    
    user = mock("user")    
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    
    observer_seq = sequence("observer_seq")
    Application.expects(:notify_observers).with(:before_recreate_dns, anything).in_sequence(observer_seq).once
    Application.expects(:notify_observers).with(:after_recreate_dns, anything).in_sequence(observer_seq).once

    container = mock("container")
    container.expects(:get_public_hostname).returns("foo.bar")
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:deregister_application).once
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:register_application).once
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:publish).once
    Cloud::Sdk::DnsService.instance.class.any_instance.expects(:close).once    
    user.expects(:namespace).returns("kraman").twice

    application.container = container
    application.recreate_dns
  end
  
  test "add alias" do
    user = mock("user")
    container = mock("container")
    
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    application.container = container
    application.expects(:aliases).returns(["foo.bar.com"]).at_least_once
    assert_raise(Cloud::Sdk::UserException){ application.add_alias("foo.bar.com") }
    
    user = mock("user")
    container = mock("container")
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    application.container = container
    container.expects(:add_alias).once.returns(ResultIO.new)
    application.expects(:save).once
    application.add_alias("foo.bar.com")
    
    user = mock("user")
    container = mock("container")
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    application.container = container
    container.expects(:add_alias).once.raises
    container.expects(:remove_alias).once.returns(ResultIO.new)
    application.expects(:save).once
    application.add_alias("foo.bar.com")
  end
  
  test "remove alias" do    
    user = mock("user")
    container = mock("container")
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    application.container = container
    application.expects(:aliases).returns(["foo.bar.com"]).at_least_once    
    
    container.expects(:remove_alias).once.returns(ResultIO.new)
    application.expects(:save).once
    application.remove_alias("foo.bar.com")
  end

  test "add dependency" do
    user = mock("user")    
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    
    observer_seq = sequence("observer_seq")
    Application.expects(:notify_observers).with(:before_add_dependency, anything).in_sequence(observer_seq).once
    Application.expects(:notify_observers).with(:after_add_dependency, anything).in_sequence(observer_seq).once

    container = mock("container")
    application.container = container
    
    container.expects(:add_component).returns([ResultIO.new, "details"])
    application.expects(:save)
    application.add_dependency("foo")
  end

  test "remove dependency" do
    user = mock("user")    
    application = Application.new(user, "app_name", "app_uuid", "std", "php-5.3")
    
    observer_seq = sequence("observer_seq")
    Application.expects(:notify_observers).with(:before_remove_dependency, anything).in_sequence(observer_seq).once
    Application.expects(:notify_observers).with(:after_remove_dependency, anything).in_sequence(observer_seq).once

    container = mock("container")
    application.container = container
    
    container.expects(:remove_component).returns(ResultIO.new)
    application.expects(:embedded).returns({"foo" => "details"}).at_least_once
    application.expects(:save)
    
    application.remove_dependency("foo")    
  end
end