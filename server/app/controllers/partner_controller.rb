class PartnerController < ApplicationController

  def index
    file = File.open("db/partners.json", "rb")
    contents = file.read
    partners = JSON.parse(contents)
    @partners = Array.new(partners.length)
    partners.each_with_index do |(partner_id, partner), i|    
      @partners[i] = Partner.new(partner)
      @partners[i].id = partner_id 
    end
  end
  
end
