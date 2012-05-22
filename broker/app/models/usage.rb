require 'rubygems'
require 'mongo'
require 'mongo_mapper'

class Usage < StickShift::Model
  include MongoMapper::Document

  VALID_GEAR_SIZES = ['small', 'medium', 'large']

  key :uuid,         String, :required => true, :unique => true
  key :user_id,      String, :required => true
  key :gear_uuid,    String, :required => true
  key :gear_size,    String, :required => true, :in => VALID_GEAR_SIZES
  key :begin_time,   Time,   :required => true
  key :end_time,     Time,   :default => nil
  attr_accessible :uuid, :user_id, :gear_uuid, :gear_size, :begin_time, :end_time

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
  
  def construct(user_id, gear_uuid, gear_size=nil,  
                begin_time=nil, end_time=nil, uuid=nil)
    self.uuid = uuid
    self.uuid = StickShift::Model.gen_uuid unless uuid
    self._id = self.uuid
    self.user_id = user_id
    self.gear_uuid = gear_uuid
    self.gear_size = gear_size
    self.begin_time = begin_time
    self.end_time = end_time
  end

  def self.find(uuid)
    super(uuid)
  end

  def self.find_by_user(user_id)
    where(:user_id => user_id).all
  end

  def self.find_by_user_after_time(user_id, time)
    where(:user_id => user_id, :begin_time => {:$gte => time}).all    
  end

  def self.find_by_user_time_range(user_id, begin_time, end_time)
    # Issue with $nor op in MongoMapper and fix available @ https://github.com/jnunemaker/plucky/issues/19
    # where(:user_id => user_id, :$nor => [ {:$and => [ {:begin_time => {:$lt => begin_time}}, {:end_time => {:$lt => begin_time}} ]},
    #                                       {:begin_time => {:$gt => end_time}} ]).all    
    # Rewriting the query to avoid $nor op                                      
    where(:user_id => user_id, :$and => [ {:$or => [ {:begin_time => {:$gte => begin_time}}, {:end_time => {:$gte => begin_time}} ]},
                                          {:begin_time => {:$lte => end_time}} ]).all    
  end

  def self.find_by_gear(gear_uuid, begin_time=nil)
    unless begin_time
      where(:gear_uuid => gear_uuid).all
    else
      where(:gear_uuid => gear_uuid, :begin_time => begin_time).all
    end
  end
  
  def self.find_latest_by_gear(gear_uuid)
    where(:gear_uuid => gear_uuid).sort(:begin_time.desc).first
  end

  def self.find_user_summary(user_id)
    usage_events = self.find_by_user(user_id)
    res = {}
    usage_events.each do |e|
      res[e.gear_size] = {} unless res[e.gear_size]
      res[e.gear_size]['num_gears'] = 0 unless res[e.gear_size]['num_gears']
      res[e.gear_size]['num_gears'] += 1
      res[e.gear_size]['consumed_time'] = 0 unless res[e.gear_size]['consumed_time']
      unless e.end_time
        res[e.gear_size]['consumed_time'] += Time.now - e.begin_time
      else
        res[e.gear_size]['consumed_time'] += e.end_time - e.begin_time
      end
    end
    res
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
