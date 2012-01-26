module Cloud
  module Sdk
    class UserModel < Model
      
      def initialize()
        super()
      end
      
      def self.find(login, id)        
        data = DataStore.instance.find(self.name,login,id)
        return nil unless data
        
        json_to_obj(data)
      end
      
      def self.find_all(login)
        data_list = DataStore.instance.find_all(self.name,login)
        return [] if data_list.empty?
        data_list.map! do |data|
          json_to_obj(data)
        end
      end
      
      def delete(login)
        id_var = self.class.pk || "uuid"
        DataStore.instance.delete(self.class.name, login, instance_variable_get("@#{id_var}"))
      end
      
      def save(login)
        id_var = self.class.pk || "uuid"
        was_persisted = @persisted
        @previously_changed = changes
        @changed_attributes.clear
        @new_record = false
        @persisted = true
        @deleted = false
        if was_persisted
          DataStore.instance.save(self.class.name, login, instance_variable_get("@#{id_var}"), self.attributes)
        else
          DataStore.instance.create(self.class.name, login, instance_variable_get("@#{id_var}"), self.attributes)
        end
        self
      end
      
      protected
      
      def self.json_to_obj(json)
        id_var = @primary_key || "uuid"
        obj = self.new.from_json(json.values[0])
        obj.instance_variable_set("@#{id_var}", json.keys[0])
        obj.reset_state
        obj
      end

    end
  end
end
