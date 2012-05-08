require 'rubygems'
require 'mongo'
require 'mongo_mapper'

class Usage < StickShift::Model
  include MongoMapper::Document

  VALID_ACTIONS = ['create', 'destroy']
  VALID_GEAR_TYPES = ['small', 'medium', 'large']

  key :uuid,       String, :required => true, :unique => true
  key :gear_uuid,  String, :required => true
  key :gear_type,  String, :required => true, :in => VALID_GEAR_TYPES
  key :action,     String, :required => true, :in => VALID_ACTIONS
  key :created_at, Time,   :required => true
  attr_accessible :uuid, :gear_uuid, :gear_type, :action, :created_at

  timestamps!  # provides attribute updated_at

  def initialize(access_info = nil)
    if access_info != nil
      # no-op
    elsif defined? Rails
      access_info = Rails.application.config.datastore
    else
      raise Exception.new("Usage Mongo DataStore service is not inilialized")
    end
    @replica_set = access_info[:replica_set]
    @host_port = access_info[:host_port]
    @user = access_info[:user]
    @password = access_info[:password]
    @db = access_info[:db]
   
    if @replica_set
      MongoMapper.connection = Mongo::ReplSetConnection.new(*@host_port << {:read => :secondary})
    else
      MongoMapper.connection = Mongo::Connection.new(@host_port[0], @host_port[1])
    end
    MongoMapper.database = @db
    MongoMapper.connection[@db].authenticate(@user, @password) if @user
  end
  
  def construct(gear_uuid, gear_type=nil, action=nil, created_at=nil)
#    self.uuid = StickShift::Model.gen_uuid
    # TODO: Fix uuid
    self.uuid = gear_uuid
    self._id = self.uuid
    self.gear_uuid = gear_uuid
    self.gear_type = gear_type
    self.action = action
    self.created_at = created_at
  end

  def self.find(uuid)
    super(uuid)
  end

  def self.find_by_gear_uuid(gear_uuid)
    where(:gear_uuid => gear_uuid).all
  end

  def self.find_all()
    all
  end

  def save(sync=true)
    self.created_at = Time.now unless self.created_at
    super({:safe => sync})
  end

  def self.delete(uuid)
    super(uuid)
  end
end
