class PartnerController < ApplicationController

  @@data = "db/partners.json"

  def index
    @partners = partners_array
  end
  
  def show
    id = params[:id]
    partners = get_partners
    Rails.logger.debug("ID: #{id}")
    unless partners.has_key?(id)
      @partners = partners_array
      render :index and return
    else
      @partner = Partner.new(partners[id])
    end
  end
  
  def join; end
  
  def get_partners
    file = File.open(@@data, "r")
    partners = nil
    begin
      contents = file.read
      partners = JSON.parse(contents)
    ensure
      file.close
    end
    return partners
  end
  
  def partners_array
    partners = get_partners
    partner_array = Array.new(partners.length)
    partners.each_with_index do |(partner_id, partner), i|    
      partner_array[i] = Partner.new(partner)
      partner_array[i].id = partner_id 
    end
    return partner_array
  end
  
end
