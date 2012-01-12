Rails.application.routes.draw do
  scope Rails.configuration.app_scope do
    match 'cartridge'       => 'legacy_broker#cartridge_post', :via => [:post]
    match 'embed_cartridge' => 'legacy_broker#embed_cartridge_post', :via => [:post]
    match 'domain'          => 'legacy_broker#domain_post', :via => [:post]
    match 'userinfo'        => 'legacy_broker#user_info_post', :via => [:post]
    match 'cartlist'        => 'legacy_broker#cart_list_post', :via => [:post]
    match 'ssh_keys'        => 'legacy_broker#ssh_keys_post', :via => [:post]    
  end
  scope "/broker/rest" do
    resource :api, :only => [:show], :controller => :base
    resource :user, :only => [:show], :controller => :user
    resources :domains, :constraints => { :id => /[A-Za-z0-9]+/ }
    resources :cartridges, :constraints => { :id => /[A-Za-z0-9]+/ }
    resources :applications, :constraints => { :id => /[A-Za-z0-9]+/ }
  end
end
