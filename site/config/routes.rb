RedHatCloud::Application.routes.draw do

  def legacy_redirect(route, target, opts={})
    opts.reverse_merge!(:defaults => {:route => target})
    opts[route] = 'product#legacy_redirect'
    match opts
  end

  # Content that has been moved to the community
  legacy_redirect 'access/express(/:request)', 'paas'
  legacy_redirect 'access/flex(/:request)', 'paas'
  legacy_redirect 'features', 'paas', :as => 'features'
  legacy_redirect 'power', 'paas'
  legacy_redirect 'about', 'paas', :as => 'about'
  legacy_redirect 'express', 'paas', :as => 'express'
  legacy_redirect 'flex', 'paas', :as => 'flex'
  legacy_redirect 'flex_redirect', 'paas', :as => 'flex_redirect'
  legacy_redirect 'platform', 'paas'

  legacy_redirect 'partners', 'partners'

  legacy_redirect 'getting_started', 'get-started'
  legacy_redirect 'getting_started/express', 'get-started'
  legacy_redirect 'getting_started/flex', 'get-started'

  legacy_redirect 'opensource', 'open-source/download-origin'
  legacy_redirect 'opensource/download', 'open-source/download-origin'

  legacy_redirect 'legal', 'legal'
  legacy_redirect 'legal/site_terms', 'legal/site_terms'
  legacy_redirect 'legal/services_agreement', 'legal/services_agreement'
  legacy_redirect 'legal/acceptable_use', 'legal/acceptable_use'
  legacy_redirect 'legal/openshift_privacy', 'legal/openshift_privacy'


  match 'getting_started_external/:registration_referrer' => 'getting_started_external#show'

  # Legacy account creation paths
  match 'email_confirm_flex' => app_redirect {|p, req| "email_confirm?#{req.query_string}"}
  match 'email_confirm_express' => app_redirect {|p, req| "email_confirm?#{req.query_string}"}
  match 'user/new' => app_redirect('account/new'), :via => [:get]
  match 'user/new/flex' => app_redirect('account/new'), :via => [:get]
  match 'user/new/express' => app_redirect('account/new'), :via => [:get]
  match 'user/complete' => app_redirect('account/complete'), :via => [:get]

  match 'account/plans' => app_redirect('account/plan'), :via => [:get]

  [
    :not_found, :error,
    :core_error, :core_not_found, :core_unavailable,
    :core_request_denied,
    :core_app_error, :core_app_unavailable, :core_app_installing,
  ].each do |sym|
    match sym.to_s => "product##{sym}"
  end
  match 'console/not_found' => 'product#console_not_found'
  match 'console/error' => 'product#console_error'

  # External feeds
  match 'twitter/latest_tweets' => 'twitter#latest_tweets'
  match 'twitter/latest_retweets' => 'twitter#latest_retweets'

  # Account Management
  resource :account,
           :controller => :account,
           :only => [:new, :create, :show] do

    get :complete, :on => :member
    get :welcome, :on => :member
    get :help, :on => :member
    get :faqs, :on => :member
    match 'contact' => 'account#contact_support', :via => :post


    resources :bills, :only => [:index, :show] do
      get :print, :on => :member
      get :export, :on => :collection, :defaults => {:format => 'csv'}
      post :locate, :on => :collection
    end
    resources :plans,   :only => :index do
      resource :upgrade, :controller => :account_upgrades, :only => [:edit, :new, :create, :show] do
        put  :edit, :action => :update, :on => :member

        resource :payment_method,
                 :controller => :account_upgrade_payment_method,
                 :only => [:show, :new, :edit] do
          get :direct_create, :on => :member
          get :direct_update, :on => :member
        end
        resource :billing_info,
                 :controller => :account_upgrade_billing_info,
                 :only => :edit do
          put :edit, :action => :update, :on => :member
        end
      end
    end
    resource :payment_method, :only => [:edit] do
      get :direct_update, :on => :member
    end
    resource :billing_info,
             :controller => :billing_info,
             :only => :edit do
      put :edit, :action => :update, :on => :member
    end
    resource :plan, :only => [:update, :show]

    resource  :password, :controller => :password do
      match 'edit' => 'password#update', :via => :put
      member do
        get :reset
        get :success
      end
    end
  end

  match 'user/create/external' => 'account#create_external', :via => [:post]

  match 'user/reset_password' => app_redirect {|p, req| "account/password/reset?#{req.query_string}"}, :via => [:get]
  match 'email_confirm' => 'email_confirm#confirm'
  match 'email_confirm_external/:registration_referrer' => 'email_confirm#confirm_external'

  match 'user' => app_redirect('account/new'), :via => [:get]

  resource :terms,
           :as => "terms",
           :controller => "terms",
           :path_names => { :new => 'accept' },
           :only => [:new, :create]

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

  scope 'console' do
    openshift_console :skip => :account
  end

  match 'new_application' => 'application_types#index', :via => :get

  resources   :download,
              :controller => 'download',
              :only => [:show,:index]

  unless Rails.env.production?
    match 'styleguide/:action' => 'styleguide'
    match 'styleguide' => 'styleguide#index'
  end

  root :to => "product#index"

  scope 'status' do
    match '/(:base)(.:format)' => StatusApp, :as => 'status'
    match '/status.js' => StatusApp, :as => 'status_js'
    match '/open_issues.js' => StatusApp, :as => 'open_issues_js'
    match '/sync/(:host)' => StatusApp, :constraints => {:host => /[0-z\.-]+/}
  end
end
