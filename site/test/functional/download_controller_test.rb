require File.expand_path('../../test_helper', __FILE__)

class DownloadControllerTest < ActionController::TestCase
  setup :with_unique_user

  test 'should redirect to open source download path' do
    get :index

    assert_redirected_to opensource_download_path
  end

  test 'should redirect to the correct download path' do
    Download.stub(:find, Download.new(:id => 3, :location => '/downloads', :filename => 'dl.zip')) do
      get :show, :id => 3
    end

    assert_redirected_to '/downloads/dl.zip'
  end

  test 'should redirect to the root download path if path is not set' do
    Download.stub(:find, Download.new(:id => 3)) do
      get :show, :id => 3
    end

    assert_redirected_to '/'
  end

  test 'should redirect to the root path if no download exists' do
    Download.stubs(:find).raises(Download::NotFound)
    get :show, :id => 3

    assert_redirected_to '/'
  end
end
