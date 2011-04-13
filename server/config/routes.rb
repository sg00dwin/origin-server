RedHatCloud::Application.routes.draw do

  scope Rails.configuration.app_scope do
    # Map all the actions on the home controller

    # The priority is based upon order of creation:
    # first created -> highest priority.

    # Sample of regular route:
    #   match 'products/:id' => 'catalog#view'
    # Keep in mind you can assign values other than :controller and :action
    match 'getting_started' => 'home#getting_started'    
    match 'email_confirm' => 'email_confirm#confirm'
    match 'broker/cartridge' => 'broker#cartridge_post', :via => [:post]
    match 'broker/domain' => 'broker#domain_post', :via => [:post]
    match 'broker/userinfo' => 'broker#user_info_post', :via => [:post]
    match 'express' => 'express#index'
    match 'flex' => 'flex#index'
    match 'power' => 'power#index'

    #Alias for home page so we can link to it
    match 'home' => 'home#index'

    # Sample of named route:
    #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
    # This route can be invoked with purchase_url(:id => product.id)

    # Sample resource route (maps HTTP verbs to controller actions automatically):
    resources :users,
              :as => "web_users",
              :constraints => { :protocol => "https" }

    resources :login, :constraints => { :protocol => "https" }

    resources :logout, :constraints => { :protocol => "https" }

    namespace "access" do
      resources :express, :as => "express"
      resources :flex, :as => "flexes"
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
  end
end
