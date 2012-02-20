class ApplicationTemplate < Cloud::Sdk::UserModel
  attr_accessor :uuid, :display_name, :descriptor_yaml, :git_url, :tags, :gear_cost, :metadata
  primary_key :uuid
  
  def initialize(display_name=nil,descriptor_yaml=nil,git_url=nil,tags=[], gear_cost=0, metadata = {})
    self.display_name, self.descriptor_yaml, self.git_url, self.tags, self.gear_cost, self.metadata =
      display_name, descriptor_yaml, git_url, tags, gear_cost, metadata
      self.uuid = Cloud::Sdk::Model.gen_uuid
  end
  
  def self.find(id)
    hash = Cloud::Sdk::DataStore.instance.find_application_template(id)
    return nil if hash.nil?
    hash.delete("_id")
    template = ApplicationTemplate.new
    template.attributes = hash
    template
  end
  
  def self.find_all()
    arr = Cloud::Sdk::DataStore.instance.find_all_application_templates()
    return nil if arr.nil?
    templates = []
    arr.each do |hash|
      hash.delete("_id")
      template = ApplicationTemplate.new
      template.attributes = hash
      templates.push(template)
    end
    templates
  end
  
  def self.find_by_tag(tag)
    arr = Cloud::Sdk::DataStore.instance.find_application_template_by_tag(tag)
    return nil if arr.nil?
    templates = []
    arr.each do |hash|
      hash.delete("_id")
      template = ApplicationTemplate.new
      template.attributes = hash
      templates.push(template)
    end
    templates
  end
  
  def delete()
    Cloud::Sdk::DataStore.instance.delete_application_template(@uuid)
  end
  
  def save()
    Cloud::Sdk::DataStore.instance.save_application_template(@uuid, self.attributes)
    @previously_changed = changes
    @changed_attributes.clear
    @new_record = false
    @persisted = true
    @deleted = false
    self
  end
end