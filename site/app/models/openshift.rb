require 'active_support/core_ext/hash/conversions'
require 'active_resource'

ActiveSupport::XmlMini.backend = 'REXML'
ActiveResource::HttpMock.respond_to do |mock|
  mock.get '/ssh_keys.xml', {}, [{:type => :rsa, :name => 'test1', :value => '1234' }].to_xml(:root => 'ssh_key')
  mock.post '/ssh_keys.xml', {}, {:type => :rsa, :name => 'test2', :value => '1234_2' }.to_xml(:root => 'ssh_key')
  mock.delete '/ssh_keys/test1.xml', {}, {}
end

class OpenshiftResource < ActiveResource::Base
  self.site = 'http://localhost'

  # Track persistence state, merged from 
  # https://github.com/railsjedi/rails/commit/9333e0de7d1b8f63b19c99d21f5f65fef0ce38c3
  #
  def initialize(attributes = {}, persisted=false)
    @persisted = persisted
    super attributes
  end

  def instantiate_record(record, prefix_options = {})
    new(record, true).tap do |resource|
      resource.prefix_options = prefix_options
    end
  end

  def new?
    !persisted?
  end

  def persisted?
    @persisted
  end

  def load_attributes_from_response(response)
    if response['Content-Length'] != "0" && response.body.strip.size > 0
      load(update_root(self.class.format.decode(response.body)))
      @persisted = true
    end
  end

  def update_root(obj)
    obj
  end
  
end

class SshKey < OpenshiftResource
  self.primary_key = 'name'

  schema do
    string :name, :key_type, :value
  end

  validates :name, :length => {:maximum => 50},
                   :presence => true,
                   :allow_blank => false
  validates_format_of :key_type,
                      :with => /^ssh-(rsa|dss)$/,
                      :message => "is not ssh-rsa or ssh-dss"
  validates :value, :length => {:maximum => 2048},
                    :presence => true,
                    :allow_blank => false

  def to_param
    name
  end
end

require 'test/unit/ui/console/testrunner'
require 'test/unit'
require 'mocha'

class OpenshiftResourceTest < Test::Unit::TestCase
  def test_get_ssh_keys
    items = SshKey.find :all
    assert_equal 1, items.length
  end

  def test_post_ssh_key
    key = SshKey.new :key_type => 'ssh-rsa', :name => 'test2', :value => '1234_2'
    assert key.save
  end

  def test_ssh_key_validation
    key = SshKey.new :key_type => 'ssh-rsa', :name => 'test2'
    assert !key.save
    assert_equal 1, key.errors[:value].length

    key.value = ''
    assert !key.save
    assert_equal 1, key.errors[:value].length

    key.value = 'a'
    assert key.save
    assert key.errors.empty?
  end

  def test_ssh_key_delete
    items = SshKey.find :all
    assert items[0].destroy
  end
end

Test::Unit::UI::Console::TestRunner.run(OpenshiftResourceTest)

items = SshKey.find :all
puts items.inspect
