class PartnerController < ApplicationController

  @@data = "db/partners.json"

  def index
    partners = get_partners
    @partners = Array.new(partners.length)
    partners.each_with_index do |(partner_id, partner), i|    
      @partners[i] = Partner.new(partner)
      @partners[i].id = partner_id 
    end
  end
  
  def show
    id = params[:id]
    partners = get_partners
    @partner = Partner.new(partners[id])
  end
  
  def get_partners
    file = File.open(@@data, "rb")
    contents = file.read
    partners = JSON.parse(contents)
  end
  
end
