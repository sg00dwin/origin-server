module Streamline
  module FullUser
    # mixin for accessing data about full users
    attr_accessor :first_name, :last_name

    def promote
      true
    end
  end
end
