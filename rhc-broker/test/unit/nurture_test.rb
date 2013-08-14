require 'test_helper'
require 'mocha/setup'

class NurtureTest < ActionDispatch::IntegrationTest

  def setup
    OpenShift::DnsService.stubs(:instance).returns(OpenShift::DnsService.new)
  end

  test "test observer is called on domain create" do
    ns = "ns" + gen_uuid[0..12]
    orig_d = Domain.new(namespace: ns)
    observer_seq = sequence("observer_seq")
    ::DomainObserver.any_instance.expects(:after_create).with(orig_d).in_sequence(observer_seq).once
    orig_d.save!
    d = Domain.find_by(canonical_namespace: ns.downcase)
    assert_equal_domains(orig_d, d)
  end

  test "test observer is called on domain update" do
    ::DomainObserver.any_instance.expects(:send_data_to_analytics).returns(true)
    ns = "ns" + gen_uuid[0..9]
    orig_d = Domain.new(namespace: ns)
    orig_d.save!

    observer_seq = sequence("observer_seq")
    ::DomainObserver.any_instance.expects(:after_update).with(orig_d).in_sequence(observer_seq).once
    orig_d.namespace = ns + "new"
    orig_d.save_with_duplicate_check!

    new_d = Domain.find_by(canonical_namespace: ns.downcase + "new")
    assert_equal_domains(orig_d, new_d)
  end

  test "nurture post" do
    credentials = Base64.encode64("nologin:nopass")
    headers = {}
    headers["HTTP_ACCEPT"] = "application/json"
    headers["HTTP_AUTHORIZATION"] = "Basic #{credentials}"
    params = { 'json_data' => '{ "action" : "create", "app_uuid" : "abcd" }' }
    request_via_redirect(:POST, "/broker/nurture", params, headers)
    assert_equal @response.status, 200
  end

  test "nurture bulk post" do
    credentials = Base64.encode64("nologin:nopass")
    headers = {}
    headers["HTTP_ACCEPT"] = "application/json"
    headers["HTTP_AUTHORIZATION"] = "Basic #{credentials}"
    params = { :nurture_action => "update_last_access", :gear_timestamps => [{:uuid => "abcd", :access_time => Time.now.strftime("%d/%b/%Y:%H:%M:%S %Z")}]}
    request_via_redirect(:POST, "/broker/nurture", params, headers)
    assert_equal @response.status, 200
  end

  def teardown
    Mocha::Mockery.instance.stubba.unstub_all
  end

  def assert_equal_domains(domain1, domain2)
    assert_equal(domain1.namespace, domain2.namespace)
    assert_equal(domain1.canonical_namespace, domain2.canonical_namespace)
    assert_equal(domain1._id, domain2._id)
  end  
end
