RedHatCloud::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Legacy redirects
  match 'access/express(/:request)' => app_redirect('express')
  match 'access/flex(/:request)' => app_redirect('flex')
  match 'features' => app_redirect('platform'), :as => 'features'
  match 'power' => app_redirect('platform')
  match 'about' => app_redirect('platform'), :as => 'about'
  match 'express' => app_redirect('platform'), :as => 'express'
  match 'flex' => app_redirect('platform'), :as => 'flex'
  match 'flex_redirect' => app_redirect('flex'), :as => 'flex_redirect'
  match 'email_confirm_flex' => app_redirect {|p, req| "email_confirm?#{req.query_string}"}
  match 'email_confirm_express' => app_redirect {|p, req| "email_confirm?#{req.query_string}"}
  match 'user/new' => app_redirect('account/new'), :via => [:get]
  match 'user/new/flex' => app_redirect('account/new'), :via => [:get]
  match 'user/new/express' => app_redirect('account/new'), :via => [:get]
  match 'user/complete' => app_redirect('account/complete'), :via => [:get]

  #Marketing site
  match 'getting_started' => 'product#getting_started', :as => 'getting_started'
  match 'getting_started/express' => app_redirect('getting_started')
  match 'getting_started/flex' => app_redirect('getting_started')
  match 'getting_started_external/:registration_referrer' => 'getting_started_external#show'
  match 'platform' => 'product#overview', :as => 'product_overview'
  #match 'partners/join' => 'partner#join', :as=> 'join_partner'
  match 'partners' => app_redirect('platform')

  #Site not found
  match 'not_found' => 'product#not_found'
  match 'error' => 'product#error'

  # Buzz
  match 'twitter_latest_tweet' => 'twitter#latest_tweet'
  match 'twitter_latest_retweets' => 'twitter#latest_retweets'

  resource :account,
           :controller => :user,
           :only => [:new, :create, :show] do

    get :complete, :on => :member

    unless Rails.env.production?
      resources :plans,   :only => :index do
        resource :upgrade, :controller => :account_upgrades, :only => [:edit, :new] do
          member do
            post :show, :action => :upgrade
            put :edit, :action => :update
          end
          resource :payment_method, :only => [:show, :new, :create]
        end
      end
      resource :plan, :only => [:update, :show]
    end

    resource  :password, :controller => :password do
      match 'edit' => 'password#update', :via => :put
      member do
        get :reset
        get :success
      end
    end
  end

  scope :account do
    resource :domain, :only => [:new, :create, :edit, :update]
    resources :keys, :only => [:new, :create, :destroy]
  end

  # preserve legacy support for this path
  match 'user/create/external' => 'user#create_external', :via => [:post]

  match 'user/reset_password' => app_redirect {|p, req| "account/password/reset?#{req.query_string}"}, :via => [:get]
  match 'email_confirm' => 'email_confirm#confirm'
  match 'email_confirm_external/:registration_referrer' => 'email_confirm#confirm_external'

  match 'user' => app_redirect('account/new'), :via => [:get]

  resource :terms,
           :as => "terms",
           :controller => "terms",
           :path_names => { :new => 'accept' },
           :only => [:new, :create]

  match 'legal/acceptance_terms' => 'terms#acceptance_terms', :as => 'acceptance_terms'

  match 'video/:name' => 'video#show', :as => 'video'

  match 'legal' => 'legal#show'
  match 'legal/site_terms' => 'legal#site_terms'
  match 'legal/services_agreement' => 'legal#services_agreement'
  match 'legal/acceptable_use' => 'legal#acceptable_use'
  match 'legal/openshift_privacy' => 'legal#openshift_privacy'

  # suggest we consolidate login/logout onto a session controller
  resource :login,
           :controller => "login",
           :only => [:show, :create]
  match 'login/flex' => 'login#show_flex', :via => [:get]
  match 'login/express' => 'login#show_express', :via => [:get]

  resource :logout,
           :controller => "logout",
           :only => [:show]
  match 'logout/flex' => 'logout#show_flex', :via => [:get]
  match 'logout/express' => 'logout#show_express', :via => [:get]

  #resources :partners,
  #          :controller => "partner",
  #          :only => [:show, :index]

  scope '/console' do
    match 'help' => 'console#help', :via => :get, :as => 'console_help'

    resources :application_types, :only => [:show, :index], :id => /[^\/]+/
    resources :applications do
      resources :cartridges, :only => [:show, :create, :index], :id => /[^\/]+/
      resources :cartridge_types, :only => [:show, :index], :id => /[^\/]+/

      resource :building, :controller => :building, :id => /[^\/]+/, :only => [:show, :new, :destroy, :create] do
        get :delete
      end

      resource :scaling, :controller => :scaling, :id => /[^\/]+/, :only => [:show, :new] do
        get :delete
      end

      member do
        get :delete
        get :get_started
      end
    end
  end

  match 'console' => 'console#index', :via => :get
  match 'new_application' => 'application_types#index', :via => :get

  match 'opensource' => 'opensource#index'
  match 'opensource/download' => 'opensource#download'
  resources   :download,
              :controller => 'download',
              :only => [:show,:index]

  unless Rails.env.production?
    match 'styleguide/:action' => 'styleguide'
    match 'styleguide' => 'styleguide#index'
  end

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"getting_started
  # just remember to delete public/index.html.
  root :to => "product#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'


  scope '/status' do
    match '/(:base)(.:format)' => StatusApp, :as => 'status'
    match '/status.js' => StatusApp, :as => 'status_js'
    match '/sync/(:host)' => StatusApp, :constraints => {:host => /[0-z\.-]+/}
  end
end
