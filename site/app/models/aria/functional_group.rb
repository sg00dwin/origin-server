module Aria
  class FunctionalGroup < Base
    def initialize(attrs)
      @attributes = attrs.is_a?(Aria::WDDX::Struct) ? attrs.attributes : attrs
    end

    def self.all
      @@all ||= Aria.cached.get_acct_groups_by_client.map {|g| new(g) }
    end

    def self.find_by_country(country)
      group_name = Rails.configuration.aria_invoice_template_map[country]
      all.find {|group| group.client_acct_group_id == group_name } if group_name
    end
  end
end
