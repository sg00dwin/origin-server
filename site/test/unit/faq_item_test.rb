require File.expand_path('../../test_helper', __FILE__)

class FaqItemTest < ActiveSupport::TestCase
  uses_http_mock

  setup { WebMock.disable_net_connect! }
  setup { Rails.cache.clear }
  teardown { WebMock.allow_net_connect! }

  def test_basic_top_ten
    faq_item = {
      :id => '9001',
      :body => 'FAQ Body',
      :href => 'http://website.com',
      :name => 'FAQ Item',
      :summary => 'Test summary',
      :updated => '1363614465'
    }

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get('/api/v1/faq/topten.json', anonymous_json_header, [ faq_item ].to_json)
    end

    assert_equal FaqItem.topten.length, 1
    assert_equal FaqItem.topten.first.attributes.to_json, faq_item.to_json
  end

  def test_basic_faqs
    faq_item = {
      :id => '9003',
      :body => 'FAQ Body',
      :href => 'http://website.com/text',
      :name => 'FAQ',
      :summary => 'Summary',
      :updated => '1461619665'
    }

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get('/api/v1/faq.json', anonymous_json_header, [ faq_item ].to_json)
    end

    assert_equal FaqItem.all.length, 1
    assert_equal FaqItem.all.first.attributes.to_json, faq_item.to_json
  end

  def test_top_ten_is_sanitized
    faq_item = {
      :id => '9010',
      :body => '<a href="javascript:alert(\'This is not good... \');">Click me</a>',
      :href => 'http://website.com',
      :name => 'Tricky FAQ Item',
      :summary => 'These types of things should not be allowed',
      :updated => '1363614465'
    }

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get('/api/v1/faq/topten.json', anonymous_json_header, [ faq_item ].to_json)
    end

    assert_equal FaqItem.topten.length, 1
    assert_equal FaqItem.topten.first.attributes.to_json, faq_item.merge(:body => '<a>Click me</a>').to_json
  end

  def test_all_is_sanitized
    faq_item = {
      :id => '9012',
      :body => '<a href="javascript:alert(\'This is not good... \');">Click me</a>',
      :href => 'http://website.com',
      :name => '<a href="javascript:alert(\'Hey!\');">Tricky FAQ Item</a>',
      :summary => 'These types of things should not be allowed',
      :updated => '1363614465'
    }

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get('/api/v1/faq.json', anonymous_json_header, [ faq_item ].to_json)
    end

    assert_equal FaqItem.all.length, 1
    assert_equal FaqItem.all.first.attributes.to_json, faq_item.merge(:body => '<a>Click me</a>', :name => '<a>Tricky FAQ Item</a>').to_json
  end

  def test_top_ten_error
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get('/api/v1/faq/topten.json', anonymous_json_header, 'Error', 500)
    end

    assert_equal FaqItem.topten, []
  end

  def test_all_error
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get('/api/v1/faq.json', anonymous_json_header, 'Error', 500)
    end

    assert_equal FaqItem.all, []
  end

end
