class District < Cloud::Sdk::Model
  
  attr_accessor :server_identities, :active_server_identities_size, :uuid, :creation_time, :available_capacity, :available_uids
  primary_key :uuid

  def initialize(uuid=nil)
    self.creation_time = DateTime::now().strftime
    self.uuid = uuid || Cloud::Sdk::Model.gen_uuid
    self.server_identities = {}
    self.available_capacity = Rails.application.config.districts[:max_capacity]
    self.available_uids = []
    self.available_uids.fill(0, Rails.application.config.districts[:max_capacity]) {|i| i+Rails.application.config.districts[:first_uid]}
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
    json = Cloud::Sdk::DataStore.instance.find_available_district()
    return nil unless json
    district = self.new.from_json(json)
    district.reset_state
    district
  end
  
  def reserve_uid()
    uid = Cloud::Sdk::DataStore.instance.reserve_district_uid(@uuid)
    #TODO fail it nil
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
    Cloud::Sdk::DataStore.instance.save_district(@uuid, self.attributes)
    self
  end
  
  def add_node(server_identity)
    if server_identity && !Cloud::Sdk::DataStore.instance.find_district_with_node(server_identity)
      unless server_identities.has_key?(server_identity)
        container = Cloud::Sdk::ApplicationContainerProxy.instance(server_identity)
        container.set_district(@uuid, true)
        server_identities[server_identity] = {"active" => true}
        Cloud::Sdk::DataStore.instance.add_district_node(@uuid, server_identity)
      end
    end
  end
  
  def remove_node(server_identity)
    if server_identities.has_key?(server_identity)
      container = Cloud::Sdk::ApplicationContainerProxy.instance(server_identity)
      container.set_district('NONE', false)
      Cloud::Sdk::DataStore.instance.remove_district_node(@uuid, server_identity)
      server_identities.delete(server_identity)
    end
  end
  
  def deactivate_node(server_identity)
    if server_identities.has_key?(server_identity)
      container = Cloud::Sdk::ApplicationContainerProxy.instance(server_identity)
      container.set_district(@uuid, false)
      server_identities[server_identity] = {"active" => false}
      Cloud::Sdk::DataStore.instance.deactivate_district_node(@uuid, server_identity)
    end
  end
  
  private

end
