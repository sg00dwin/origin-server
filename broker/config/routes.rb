Broker::Application.routes.draw do
  scope Rails.configuration.app_scope do
    # Map all the actions on the home controller

    # The priority is based upon order of creation:
    # first created -> highest priority.

    # Sample of regular route:
    #   match 'products/:id' => 'catalog#view'
    # Keep in mind you can assign values other than :controller and :action
    match 'nurture' => 'broker#nurture_post', :via => [:post]
    scope "/rest" do
      resources :application_template
      resources :domains, :constraints => { :id => /[A-Za-z0-9]+/ } do
        resources :applications, :controller => :extended_applications, :constraints => { :id => /[\w]+/ } do
          resource :descriptor, :only => [:show]
          resources :cartridges, :controller => :emb_cart, :only => [:index, :create, :destroy], :constraints => { :id => /[\w\-\.]+/ } do
              resources :events, :controller => :emb_cart_events, :only => [:create]
          end
          resources :events, :controller => :app_events, :only => [:create]
        end
      end
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
    #root :to => "home#index"

    # See how all your routes lay out with "rake routes"

    # This is a legacy wild controller route that's not recommended for RESTful applications.
    # Note: This route will make all actions in every controller accessible via GET requests.
    # match ':controller(/:action(/:id(.:format)))'
  end
end
