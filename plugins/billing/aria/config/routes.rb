Rails.application.routes.draw do
  scope "/broker/billing/rest" do
    resource :api, :only => :show, :controller => :api
    resources :events, :controller => :billing_events, :only => [:create]
  end
end
