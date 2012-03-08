RedHatCloud::Application.routes.draw do

  scope Rails.configuration.app_scope do
    # Map all the actions on the home controller

    # The priority is based upon order of creation:
    # first created -> highest priority.

    # Legacy redirects
    match 'getting_started/express', :to => redirect('/app/express')
    match 'getting_started/flex', :to => redirect('/app/flex')
    match 'access/express(/:request)', :to => redirect('/app/express')
    match 'access/flex(/:request)', :to => redirect('/app/flex')

    # Sample of regular route:
    #   match 'products/:id' => 'catalog#view'
    # Keep in mind you can assign values other than :controller and :action
    match 'getting_started' => 'getting_started/generic#show'
    match 'getting_started_external/:registration_referrer' => 'getting_started_external#show'
    match 'email_confirm' => 'email_confirm#confirm'
    match 'email_confirm_external/:registration_referrer' => 'email_confirm#confirm_external'
    match 'email_confirm_flex' => 'email_confirm#confirm_flex'
    match 'email_confirm_express' => 'email_confirm#confirm_express'
    match 'express' => 'product#express', :as => 'express'
    match 'flex' => 'product#flex', :as => 'flex'
    match 'platform' => 'product#overview', :as => 'product_overview'
    match 'features' => 'product#features', :as => 'features'
    match 'express_protected' => 'product#express_protected', :as => 'express_protected'
    match 'flex_protected' => 'product#flex_protected', :as => 'flex_protected'
    match 'power', :to => redirect('/app/platform')
    match 'flex_redirect' => 'product#flex_redirect', :as => 'flex_redirect'
    match 'about' => 'home#about', :as => 'about'
    match 'twitter_latest_tweet' => 'twitter#latest_tweet'
    match 'twitter_latest_retweets' => 'twitter#latest_retweets'
    match 'partners/join' => 'partner#join', :as=> 'join_partner'

    resource :account,
             :controller => "user",
             :only => [:new, :create, :show]

    scope '/account' do
      resource :password,
               :controller => "password" do
        match 'edit' => 'password#update', :via => :put
        match 'reset' => 'password#edit_with_token', :via => :get
        match 'success' => 'password#success', :via => :get
      end
      resource :express_domains,
               :controller => "express_domain" do
        match 'edit_namespace' => 'express_domain#account_update', :via => :put
        match 'edit_sshkey' => 'express_domain#account_update', :via => :put
        match 'edit_namespace' => 'express_domain#edit_namespace', :via => :get
        match 'edit_sshkey' => 'express_domain#edit_sshkey', :via => :get
      end
      resource :express_sshkeys,
               :controller => "express_ssh_keys" do
        match 'add_sshkey' => 'express_ssh_keys#add_sshkey', :via => :get
        match 'add_sshkey' => 'express_ssh_keys#create', :via => :post
        match 'edit_sshkey/:key_name' => 'express_ssh_keys#edit_sshkey', :via => :get
        match 'edit_sshkey' => 'express_ssh_keys#create', :via => :put
        match 'delete_sshkey/:key_name' => 'express_ssh_keys#delete_sshkey', :via => :delete
      end

      resource :domain, :only => [:new, :create, :edit, :update]
      resources :keys, :only => [:new, :create, :destroy]
    end

    # deprecated, move to :account
    resource :user,
             :path => :account,
             :as => "web_user",
             :controller => "user",
             :only => [:new, :create, :show]
    match 'user/new/flex' => 'user#new_flex', :via => [:get]
    match 'user/new/express' => 'user#new_express', :via => [:get]
    match 'user/create/external' => 'user#create_external', :via => [:post]
    match 'user/complete' => 'user#complete', :via => [:get]
    # legacy routes
    match 'user' => 'user#create', :as => :web_users, :via => [:post]
    match 'user/new' => 'user#new', :as => :new_web_users, :via => [:get]
    match 'user' => 'user#new', :as => :user, :via => [:get]
    #match 'user' => 'user#show', :via => :get

    # deprecated, use :password
    match 'user/request_password_reset' => 'user#request_password_reset', :via => [:post]
    match 'user/reset_password' => 'user#reset_password', :via => [:get]
    match 'user/change_password' => 'user#change_password', :via => [:post]

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
    match 'login/error' => 'login#error', :via => [:get]
    match 'login/flex' => 'login#show_flex', :via => [:get]
    match 'login/express' => 'login#show_express', :via => [:get]
    match 'login/ajax' => 'login#ajax', :via => [:post]

    resource :logout,
             :controller => "logout",
             :only => [:show]
    match 'logout/flex' => 'logout#show_flex', :via => [:get]
    match 'logout/express' => 'logout#show_express', :via => [:get]

    resources :partners,
              :controller => "partner",
              :only => [:show, :index]

    resource :express_domain,
             :controller => "express_domain",
             :as => "express_domains",
             :only => [:new, :create]
  
    resource  :express_app,
              :controller => "express_app",
              :as => "express_apps",
              :only => [:new, :create]

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
    match 'new_application' => 'application_types#index', :via => :get

    resources :express_ssh_keys

    match 'express_ssh_key_delete' => 'express_ssh_keys#destroy', :via => [:post]
    match 'express_app_delete' => 'express_app#destroy', :via => [:post]
    match 'control_panel' => 'control_panel#index', :as => 'control_panel'
    match 'dashboard' => 'control_panel#index', :as => 'dashboard'
    match 'control_panel/apps' => 'express_app#list', :as => 'list_apps'
    
    # new marketing site
    match 'new' => 'site#index', :via => [:get]
    match 'new/express' => 'site#express', :via => [:get]
    match 'signup' => 'site#signup', :as => :user, :via => [:get]
    match 'signin' => 'site#signin', :as => :user, :via => [:get]

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
    root :to => "home#index"

    # See how all your routes lay out with "rake routes"

    # This is a legacy wild controller route that's not recommended for RESTful applications.
    # Note: This route will make all actions in every controller accessible via GET requests.
    # match ':controller(/:action(/:id(.:format)))'


    scope '/status' do
      match '/(:id)(.:format)', :to => StatusApp
      match '/sync/(:host)', :to => StatusApp, :constraints => {:host => /[0-z\.-]+/}
    end
    #mount StatusApp => '/status',
  end
end
