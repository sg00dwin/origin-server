require 'ostruct'
require 'yaml'
require 'countries'

# These are additional attributes we define in countries.yml
class Country
  attr_accessor :subdivision_name
  attr_accessor :postal_code_name

  def currency
    Rails.configuration.currency_cd_by_country[alpha2].upcase
  end
end

module CountryHelper
  def countries_for_select
    CountryHelper.countries.map do |country|
      data = {
        :currency    => country.currency,
        :subdivision => country.subdivision_name,
        :postal_code => country.postal_code_name
      }.delete_if{|_,v| v.nil?}

      [country.name, country.alpha2, Hash[data.map{|k,v| ["data-#{k}",v] } ] ]
    end
  end

  def regions_for_select(maxlength=1024)
    # The Country gem adds some extra information in parens at the end of some entries
    CountryHelper.subdivisions.map do |c,s| 
      [
        c.name,
        s.map do |(key,data)| 
          name = data['name'].split('(').first
          value = /\D/.match(key) ? key : name # Use the full name instead of all-numeric identifiers
          [name, value.slice(0,maxlength), {'data-country' => c.alpha2}]
        end
      ]
    end
  end

  class << self
    def countries
      @@countries ||= preferred_sort(config.allowed_countries, config.preferred_countries, :alpha2, :name)
    end

    def subdivisions
      @@subdivisions ||= Hash[countries.map{|c| [c, c.subdivisions] }]
    end

    def config
      @@config ||= OpenStruct.new(YAML.load_file(File.join(Rails.root, 'config', 'countries.yml'))).tap do |c|
          [:allowed_countries, :preferred_countries].each do |x|
            c.send("#{x}=",Rails.configuration.send(x).map{|y| y.to_s.upcase })
          end
          # Loop through all of the allowed countries and set additional info from our countries.yml
          c.allowed_countries.map! do |code|
            Country[code].tap do |country|
              # Merge the additional info with the defaults
              c.defaults.merge(c.additional_info[code] || {}).each do |key,val|
                country.send("#{key}=",val)
              end
            end
          end
      end
    end

    private
    # Sort the array by the position in the order array
    def preferred_sort(array, order, index = :to_s, sort_key = :to_s)
      array.sort_by do |x|
        [ order.index(x.send(index)) || order.size, x.send(sort_key)]
      end
    end
  end
end
