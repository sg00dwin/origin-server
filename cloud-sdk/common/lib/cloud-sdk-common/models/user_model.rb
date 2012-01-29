module Cloud
  module Sdk
    class UserModel < Model
      
      def initialize()
        super()
      end
      
      def self.find(login, id)        
        hash = DataStore.instance.find(self.name,login,id)
        return nil unless hash
        
        hash_to_obj(hash)
      end
      
      def self.find_all(login)
        hash_list = DataStore.instance.find_all(self.name,login)
        return [] if hash_list.empty?
        hash_list.map! do |hash|
          hash_to_obj(hash)
        end
      end
      
      def delete(login)
        id_var = self.class.pk || "uuid"
        DataStore.instance.delete(self.class.name, login, instance_variable_get("@#{id_var}"))
      end
      
      def save(login)
        id_var = self.class.pk || "uuid"
        if @persisted
          if supports_partial_updates?
            unless changes.empty?
              changed_attrs = {}
              changes.each do |key, value|
                changed_attrs[key] = value[1]
              end
              DataStore.instance.save(self.class.name, login, instance_variable_get("@#{id_var}"), changed_attrs)
            end
          else
            DataStore.instance.save(self.class.name, login, instance_variable_get("@#{id_var}"), self.attributes)
          end
        else
          DataStore.instance.create(self.class.name, login, instance_variable_get("@#{id_var}"), self.attributes)
        end
        @previously_changed = changes
        @changed_attributes.clear
        @new_record = false
        @persisted = true
        @deleted = false
        self
      end
      
      protected
      
      def supports_partial_updates?
        return true
      end
      
      def self.json_to_obj(json)
        obj = self.new.from_json(json)
        obj.reset_state
        obj
      end
      
      def self.hash_to_obj(hash)
        obj = self.new 
        hash.each do |k,v|
          obj.instance_variable_set("@#{k}", v)
        end
        obj.reset_state
        obj
      end

    end
  end
end
