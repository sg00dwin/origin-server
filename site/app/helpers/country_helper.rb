require 'ostruct'
require 'yaml'
require 'countries'

# These are additional attributes we define in countries.yml
class Country
  attr_accessor :subdivision_name
  attr_accessor :postal_code_name
end

module CountryHelper
  def countries_for_select
    CountryHelper.countries.map do |country|
      currency = country.currency.code
      data = {
        :currency => (CountryHelper.currencies.include?(currency) ? currency.downcase : 'usd'),
        :subdivision => country.subdivision_name,
        :postal_code => country.postal_code_name
      }.delete_if{|_,v| v.nil?}

      [country.name, country.alpha2, Hash[data.map{|k,v| ["data-#{k}",v] } ] ]
    end
  end

  def regions_for_select
    CountryHelper.subdivisions.map{|c,s| [c.name, s.map{|sub| [sub.last['name'], sub.first, {'data-country' => c.alpha2} ] }] }
  end

  def currencies_for_select
    currencies = CountryHelper.currencies
    currencies.zip(currencies.map(&:downcase))
  end

  class << self
    def countries
      @@countries ||= preferred_sort(config.allowed_countries, config.preferred_countries, :alpha2, :name)
    end

    def currencies
      @@currencies ||= config.allowed_currencies
    end

    def subdivisions
      @@subdivisions ||= Hash[countries.map{|c| [c, c.subdivisions] }]
    end

    def config
      @@config ||= OpenStruct.new(YAML.load_file(File.join(Rails.root, 'config', 'countries.yml'))).tap do |c|
          [:allowed_currencies, :allowed_countries, :preferred_countries].each do |x|
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
