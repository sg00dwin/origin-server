require 'active_record'

class Issue < ActiveRecord::Base
  has_many :updates, :order => "created_at ASC"
  validates_presence_of   :title

  def status
    @resolved_at.nil? ? :investigating : :resolved
  end

  def resolved?
    not @resolved_at.nil?
  end

  def resolve
    if updates.empty? or updates.last.changed?
      errors[:updates] << "No update was provided with the resolution or the last update was not saved"
      false
    else
      self.resolved_at = updates.last.created_at
      save
    end
  end

  scope :resolved, :conditions => 'resolved_at IS NOT NULL', :order => 'resolved_at DESC'
  scope :is_open, :conditions => {:resolved_at => nil}, :order => 'resolved_at DESC'
  scope :unresolved, :conditions => {:resolved_at => nil}, :order => 'resolved_at DESC'

  def self.year(year=nil)
    year ||= Date.today.year
    where("created_at > ?",DateTime.new(year))
  end
end

class Update < ActiveRecord::Base
  belongs_to :issue

  validates_length_of   :description, :minimum => 10
end
