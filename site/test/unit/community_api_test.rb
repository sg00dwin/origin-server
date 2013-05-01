require File.expand_path('../../test_helper', __FILE__)

class CommunityApiTest < ActiveSupport::TestCase

  def test_relative_url_sanitizer
    sample_html = "Test HTML <a href='/community/page' /> TEST"
    no_change_sample_html = "Test HTML <a href=\"http://test.openshift.com:8118/community/page\" /> TEST"
  	[
      # sanitized result , community site
      ["Test HTML <a href=\"http://test.openshift.com/community/page\" /> TEST", "http://test.openshift.com/"],
      ["Test HTML <a href=\"http://test.openshift.com:8118/community/page\" /> TEST", "http://test.openshift.com:8118/"],
      ["Test HTML <a href=\"http://test.openshift.com/community/page\" /> TEST", "http://test.openshift.com/path/"],
      ["Test HTML <a href=\"http://test.openshift.com:8118/community/page\" /> TEST", "http://test.openshift.com:8118/path/"],
    ].each do |val, site|
      # sanitize html sample with relative URL
      CommunityApi::Base::RelativeURLSanitizer.any_instance.expects(:site).returns(site)
      sanitized = CommunityApi::Base.url_sanitizer.sanitize sample_html
      assert_equal val, sanitized
      # sanitize html sample with absolute URL
      sanitized = CommunityApi::Base.url_sanitizer.sanitize no_change_sample_html
      assert_equal no_change_sample_html, sanitized
    end
  end

end