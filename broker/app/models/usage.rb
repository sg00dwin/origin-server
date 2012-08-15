require 'rubygems'
require 'mongo'
require 'mongo_mapper'

class Usage < StickShift::Model
  include MongoMapper::Document

  VALID_GEAR_SIZES = ['small', 'medium', 'large', 'c9']

  key :uuid,         String, :required => true, :unique => true
  key :login,        String, :required => true
  key :gear_uuid,    String, :required => true
  key :begin_time,   Time,   :required => true
  key :end_time,     Time,   :default => nil
  key :usage_type,   String, :required => true, :in => UsageRecord::USAGE_TYPES.values
  key :gear_size,    String,                    :in => VALID_GEAR_SIZES
  key :addtl_fs_gb,  Fixnum

  attr_accessible :uuid, :login, :gear_uuid, :begin_time, :end_time, :gear_size, :addtl_fs_gb, :usage_type

  timestamps!  # provides attribute updated_at

  def initialize(login, gear_uuid, begin_time=nil, end_time=nil, uuid=nil, usage_type=nil)
    self.uuid = uuid
    self.uuid = StickShift::Model.gen_uuid unless uuid
    self._id = self.uuid
    self.login = login
    self.gear_uuid = gear_uuid
    self.begin_time = begin_time
    self.end_time = end_time
    self.usage_type = usage_type
  end

  def self.find(uuid)
    super(uuid)
  end

  def self.find_by_user(login)
    where(:login => login).all
  end

  def self.find_by_user_after_time(login, time)
    where(:login => login, :begin_time => {:$gte => time}).all    
  end

  def self.find_by_user_time_range(login, begin_time, end_time)
    # Issue with $nor op in MongoMapper and fix available @ https://github.com/jnunemaker/plucky/issues/19
    # where(:login => login, :$nor => [ {:$and => [ {:begin_time => {:$lt => begin_time}}, {:end_time => {:$lt => begin_time}} ]},
    #                                       {:begin_time => {:$gt => end_time}} ]).all    
    # Rewriting the query to avoid $nor op                                      
    where(:login => login, :$and => [ {:$or => [ {:begin_time => {:$gte => begin_time}}, {:end_time => {:$gte => begin_time}} ]},
                                          {:begin_time => {:$lte => end_time}} ]).all    
  end

  def self.find_by_gear(gear_uuid, begin_time=nil)
    unless begin_time
      where(:gear_uuid => gear_uuid).all
    else
      where(:gear_uuid => gear_uuid, :begin_time => begin_time).all
    end
  end
  
  def self.find_latest_by_gear(gear_uuid, usage_type)
    where(:gear_uuid => gear_uuid, :usage_type => usage_type).sort(:begin_time.desc).first
  end

  def self.find_user_summary(login)
    usage_events = self.find_by_user(login)
    res = {}
    usage_events.each do |e|
      res[e.gear_size] = {} unless res[e.gear_size]
      res[e.gear_size]['num_gears'] = 0 unless res[e.gear_size]['num_gears']
      res[e.gear_size]['num_gears'] += 1
      res[e.gear_size]['consumed_time'] = 0 unless res[e.gear_size]['consumed_time']
      unless e.end_time
        res[e.gear_size]['consumed_time'] += Time.now.utc - e.begin_time
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
