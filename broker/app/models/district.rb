class District < Cloud::Sdk::Model
  
  attr_accessor :server_identities, :uuid, :creation_time, :capacity, :uids
  primary_key :uuid

  def initialize(uuid=nil)
    self.creation_time = DateTime::now().strftime
    self.uuid = uuid || Cloud::Sdk::Model.gen_uuid
    self.server_identities = []
    self.capacity = 0
    self.uids = []
  end
  
  def self.find(uuid)
    json = Cloud::Sdk::DataStore.instance.find_district(uuid)
    return nil unless json
    district = self.new.from_json(json)
    district.reset_state
    district
  end
  
  def self.find_all()
    data = Cloud::Sdk::DataStore.instance.find_all_districts()
    return [] unless data
    districts = data.map do |json|
      district = self.new.from_json(json)
      district.reset_state
      district
    end
    districts
  end

  def self.find_available()
    data = Cloud::Sdk::DataStore.instance.find_all_districts()
    return [] unless data
    districts = data.map do |json|
      district = self.new.from_json(json)
      district.reset_state
      district
    end
    available_capacity = Rails.application.config.districts[:max_capacity]
    available_district = nil
    districts.each do |district|
      unless district.server_identities.empty?
        capacity = district.capacity
        if capacity < available_capacity && capacity < Rails.application.config.districts[:max_capacity]
          available_capacity = capacity
          available_district = district
        end
      end
    end
    available_district
  end
  
  def available_uid()
    uid = Rails.application.config.districts[:first_uid]
    unless @uids.empty?
      @uids.each_with_index do |next_used_uid, index|
        if uid != next_used_uid
          @uids.insert(index, uid)
          break
        else
          uid += 1
          if index == @uids.length - 1
            @uids << uid
            break
          end
        end
      end
    else
      @uids << uid
    end
    return uid
  end
  
  def delete()
    Cloud::Sdk::DataStore.instance.delete_district(@uuid)
  end
  
  def save()
    @previously_changed = changes
    @changed_attributes.clear
    @new_record = false
    @persisted = true
    @deleted = false
    Cloud::Sdk::DataStore.instance.save_district(@uuid, self.to_json)
    self
  end
  
  def add_node(server_identity)
    if server_identity
      unless server_identities.include? server_identity
        container = Cloud::Sdk::ApplicationContainerProxy.instance(server_identity)
        container.set_district(@uuid)
        server_identities << server_identity
      end
    end
  end
  
  def remove_node(server_identity)
    container = Cloud::Sdk::ApplicationContainerProxy.instance(server_identity)
    container.set_district('NONE')
    server_identities.delete(server_identity)
  end
  
  def mark_remove_node(server_identity)
  end
  
  private

end
