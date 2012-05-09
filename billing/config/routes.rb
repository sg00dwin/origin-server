Billing::Application.routes.draw do
  scope "/rest" do
    resource :api, :only => [:show], :controller => :base
    resources :events, :controller => :billing_events, :only => [:create]
  end
end
