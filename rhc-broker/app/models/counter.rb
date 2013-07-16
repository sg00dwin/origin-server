module OpenShift
  # Provides generic atomic counter
  # @!attribute [rw] name
  #   @return [String] Name of the counter
  # @!attribute [r] sequence
  #   @return [Integer] Stores current sequence number
  class Counter
    include Mongoid::Document
    include Mongoid::Timestamps

    field :name, type: String
    field :sequence, type: Integer, default: 0

    validates :name, presence: true

    index({:name => 1}, {:unique => true})
    create_indexes 

    def self.create(name, base_sequence)
      create!(name: name, sequence: base_sequence) 
    end

    def self.get_next_sequence(name)
      Rails.logger.debug "get_next_sequence, name: #{name}"
      query = {:name => name}
      update = {"$inc" => {:sequence => 1}}
      options = {:new => true, :upsert => true}
      counter_obj = where(query).find_and_modify(update, options)
      raise Exception.new "Unable to get next available sequence for #{name}" unless counter_obj
      counter_obj.sequence
    end
  end
end
