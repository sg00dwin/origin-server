class CartridgesController < BaseController
  respond_to :html, :xml, :json
  
  # GET /cartridges
  def index
    carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("standalone")}
    @result = Result.new(:ok, "cartridges", carts)
    respond_with(@result, :status => :ok)
  end
  
  # GET /cartridges/embedded
  def embedded
    carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("embedded")}
    @result = Result.new(:ok, "embedded cartridges", carts)
    respond_with(@result, :status => :ok)
  end
  
  
end

