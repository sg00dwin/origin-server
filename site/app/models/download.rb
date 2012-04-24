class Download
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  class NotFound < StandardError
  end

  attr_accessor :id, :name, :location
  attr_accessor :type, :size, :filename

  DEFAULT_LOCATION = 'http://mirror.openshift.com/pub/'

  def initialize(attributes={})
    attributes[:location] ||= DEFAULT_LOCATION

    attributes.each do |name,value|
      send("#{name}=", value)
    end
  end

  def path
    return File.join(@location,@filename)
  end

  def to_param
    return @id
  end

  files = [
    {
      :id => 'remix',
      :name => 'OpenShift Origin LiveCD',
      :filename => 'openshift_origin_livecd.iso',
      :type => 'application/x-iso9660-image',
      :size => 1102053376,
      :location => File.join(DEFAULT_LOCATION,%w(fedora-remix 16 x86_64))
    }
  ]

  @files = files.map { |t| Download.new t }

  class << self
    def find(id)
      case id
      when String
        @files.find { |file| file.id == id } or raise NotFound
      else
        raise "Unsupported scope"
      end
    end
  end
end
