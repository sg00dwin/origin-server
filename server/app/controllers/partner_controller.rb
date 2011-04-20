class PartnerController < ApplicationController

  def index
    file = File.open("db/partners.json", "rb")
    contents = file.read
    @partners = JSON.parse(contents)
  end  
  
end
