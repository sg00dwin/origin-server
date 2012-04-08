Rails.application.routes.draw do

  resource :account,
           :controller => "user",
           :only => [:show] do
  end

  scope '/account' do
    resource :domain, :only => [:new, :create, :edit, :update]
    resources :keys, :only => [:new, :create, :destroy]
  end

  scope '/console' do
    match 'help' => 'console#help', :via => :get, :as => 'console_help'

    resources :application_types, :only => [:show, :index], :id => /[^\/]+/
    resources :applications,
              :controller => "applications" do 
      resources :cartridges,
                :controller => "cartridges",
                :only => [:show, :create, :index], :id => /[^\/]+/
      resources :cartridge_types, :only => [:show, :index], :id => /[^\/]+/
      member do
        get :delete
        get :get_started
      end
    end
  end

  match 'console' => 'console#index', :via => :get
end
