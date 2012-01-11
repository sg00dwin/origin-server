class AppController < BaseController
  respond_to :html, :xml, :json
  
  # GET /cartridges
  def index
    @carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges(cart_type)}
    @result = Result.new(:ok, "cartridges", @carts)
    respond_with(@result, :status => :ok)
  end
end

