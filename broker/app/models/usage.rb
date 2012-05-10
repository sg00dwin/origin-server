require 'rubygems'
require 'mongo'
require 'mongo_mapper'

class Usage < StickShift::Model
  include MongoMapper::Document

  VALID_ACTIONS = ['create', 'destroy']
  VALID_GEAR_TYPES = ['small', 'medium', 'large']

  key :uuid,         String, :required => true, :unique => true
  key :user_id,      String, :required => true
  key :gear_uuid,    String, :required => true
  key :gear_type,    String, :required => true, :in => VALID_GEAR_TYPES
  key :action,       String, :required => true, :in => VALID_ACTIONS
  key :create_time,  Time,   :required => true
  key :destroy_time, Time,   :default => nil
  attr_accessible :uuid, :user_id, :gear_uuid, :gear_type, :action, :create_time, :destroy_time

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
  
  def construct(user_id, gear_uuid, gear_type=nil, action=nil, 
                create_time=nil, destroy_time=nil, uuid=nil)
    self.uuid = uuid
    self.uuid = StickShift::Model.gen_uuid unless uuid
    self._id = self.uuid
    self.user_id = user_id
    self.gear_uuid = gear_uuid
    self.gear_type = gear_type
    self.action = action
    self.create_time = create_time
    self.destroy_time = destroy_time
  end

  def self.find(uuid)
    super(uuid)
  end

  def self.find_by_user(user_id)
    where(:user_id => user_id).all
  end

  def self.find_by_user_after_time(user_id, time)
    where(:user_id => user_id, :create_time => {:$gte => time}).all    
  end

  def self.find_by_user_time_range(user_id, begin_time, end_time)
    # Issue with $nor op in MongoMapper and fix available @ https://github.com/jnunemaker/plucky/issues/19
    # where(:user_id => user_id, :$nor => [ {:$and => [ {:create_time => {:$lt => begin_time}}, {:destroy_time => {:$lt => begin_time}} ]},
    #                                       {:create_time => {:$gt => end_time}} ]).all    
    # Rewriting the query to avoid $nor op                                      
    where(:user_id => user_id, :$and => [ {:$or => [ {:create_time => {:$gte => begin_time}}, {:destroy_time => {:$gte => begin_time}} ]},
                                          {:create_time => {:$lte => end_time}} ]).all    
  end

  def self.find_by_gear(gear_uuid)
    where(:gear_uuid => gear_uuid).all
  end

  def self.find_all()
    all
  end

  def save(sync=true)
    super({:safe => sync})
  end

  def self.delete(uuid)
    super(uuid)
  end
end
