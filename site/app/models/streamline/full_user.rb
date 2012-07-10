module Streamline
  class FullUser
    include ActiveModel::Serialization
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :first_name, :last_name

    def initialize(opts=nil)
    end

    def persisted?
      false
    end
  end
end
