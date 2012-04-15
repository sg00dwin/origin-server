Rails.application.routes.draw do

  scope '/console' do

    # Help
    match 'help' => 'console#help', :via => :get, :as => 'console_help'

    # Application specific resources
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

    # Account specific resources
    resource :account,
             :controller => "user",
             :only => [:show]

    scope '/account' do
      resource :domain, :only => [:new, :create, :edit, :update]
      resources :keys, :only => [:new, :create, :destroy]
    end

  end

  match 'console' => 'console#index', :via => :get

  root :to => app_redirect('console')
end
