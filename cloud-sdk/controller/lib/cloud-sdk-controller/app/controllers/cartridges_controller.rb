class CartridgesController < BaseController
  respond_to :html, :xml, :json
  
  # GET /cartridges
  def index
    cart_type = "standalone"
    cache_key = "cart_list_#{cart_type}"
    carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges(cart_type)}
    @result = Result.new(:ok, "cartridges", carts)
    respond_with(@result, :status => :ok)
  end
  
  # GET /cartridges/embedded
  def embedded
    cart_type = "embedded"
    cache_key = "cart_list_#{cart_type}"
    carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges(cart_type)}
    @result = Result.new(:ok, "embedded cartridges", carts)
    respond_with(@result, :status => :ok)
  end
  
  
end

