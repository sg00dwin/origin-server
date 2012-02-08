class Issue
  include DataMapper::Resource

  property :id,           Serial
  property :title,        String
  #property :description,  Text,     :lazy => false
  property :resolved_at,  DateTime, :writer => :private
  property :created_at,   DateTime

  has n, :updates, :order => [:created_at.asc]

  validates_presence_of   :title

  def status
    @resolved_at.nil? ? :investigating : :resolved
  end

  def resolved?
    not @resolved_at.nil?
  end

  def resolve
    if updates.empty? or updates.last.dirty?
      errors[:updates] << "No update was provided with the resolution or the last update was not saved"
      false
    else
      self.resolved_at = updates.last.created_at
      save
    end
  end

  def self.resolved
    all :resolved_at.not => nil, :order => [:created_at.desc]
  end
  def self.open
    all :resolved_at => nil, :order => [:created_at.desc]
  end
  def self.year(year=nil)
    year ||= Date.today.year
    all :created_at.gt => DateTime.new(year)
  end
end

class Update
  include DataMapper::Resource

  property :id,           Serial
  property :description,  Text,    :lazy => false
  property :created_at,   DateTime

  belongs_to :issue

  validates_length_of   :description, :min => 10
end
