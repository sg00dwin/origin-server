require File.expand_path('../../test_helper', __FILE__)

class DownloadTest < ActiveSupport::TestCase

  def test_path
    dl = Download.new(:location => 'http://openshift.com/', :filename => 'download.zip')

    assert_equal 'http://openshift.com/download.zip', dl.path
  end

  def test_path_nil
    assert_nil Download.new.path
  end

  def test_path_nil_with_location
    assert_nil Download.new(:location => 'http://downloading.com').path
  end

  def test_path_default_location
    assert_equal 'http://mirror.openshift.com/pub/writeup.pdf', Download.new(:filename => 'writeup.pdf').path
  end

  def test_to_param
    assert_equal 46, Download.new(:id => 46).to_param
  end

  def test_find_remix
    assert_equal 'OpenShift Origin LiveCD', Download.find('remix').name
  end

  def test_find_not_found
    assert_raise Download::NotFound do
      Download.find('not_here')
    end
  end

  def test_find_unsupported_scope
    assert_raise RuntimeError do
      Download.find(455)
    end
  end

end
