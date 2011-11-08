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
    match 'power' => 'product#power', :as => 'power'
    match 'flex_redirect' => 'product#flex_redirect', :as => 'flex_redirect'
    match 'about' => 'home#about', :as => 'about'
    match 'twitter_latest_tweet' => 'twitter#latest_tweet'
    match 'twitter_latest_retweets' => 'twitter#latest_retweets'
    match 'partners/join' => 'partner#join', :as=> 'join_partner'

    #Alias for home page so we can link to it
    #match 'home' => 'home#index'

    # Sample of named route:
    #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
    # This route can be invoked with purchase_url(:id => product.id)

    # Sample resource route (maps HTTP verbs to controller actions automatically):
    resource :user,
             :controller => "user",
             :as => "web_users",
             :only => [:new, :create]

    match 'user/new/flex' => 'user#new_flex', :via => [:get]
    match 'user/new/express' => 'user#new_express', :via => [:get]
    get 'user' => 'user#new'
    match 'user/create/external' => 'user#create_external', :via => [:post]
    match 'user/complete' => 'user#complete', :via => [:get]

    match 'user/reset_password' => 'user#reset_password', :via => [:post]
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
        
    match 'express_app_delete' => 'express_app#destroy', :via => [:post]
    match 'control_panel' => 'control_panel#index', :as => 'control_panel'
    match 'dashboard' => 'control_panel#index', :as => 'dashboard'
    match 'control_panel/apps' => 'express_app#list', :as => 'list_apps'

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
  end
end
