class CartridgesController < BaseController
  respond_to :html, :xml, :json
  
  # GET /cartridges
  def index
    cartridges = Array.new
    cart_type = "standalone"
    cache_key = "cart_list_#{cart_type}"
    carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges(cart_type)}
    carts.each do |cart|
      cartridge = RestCartridge.new(cart_type, cart)
      cartridges.push(cartridge)
    end
    cart_type = "embedded"
    cache_key = "cart_list_#{cart_type}"
    carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges(cart_type)}
    carts.each do |cart|
      cartridge = RestCartridge.new(cart_type, cart)
      cartridges.push(cartridge)
    end
    @reply = RestReply.new(:ok, "cartridges", cartridges)
    respond_with @reply, :status => @reply.status
  end
  
  # GET /cartridges/id
  def show
    cart_type = params[:id]
    cache_key = "cart_list_#{cart_type}"
    carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges(cart_type)}
    cartridges = Array.new
    carts.each do |cart|
      cartridge = RestCartridge.new(cart_type, cart)
      cartridges.push(cartridge)
    end
    @reply = RestReply.new(:ok, "cartridges", cartridges)
    respond_with @reply, :status => @reply.status
  end
  
  
end

