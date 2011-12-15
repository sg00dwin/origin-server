Rails.application.routes.draw do
  scope Rails.configuration.app_scope do
    match 'cartridge'       => 'legacy_broker#cartridge_post', :via => [:post]
    match 'embed_cartridge' => 'legacy_broker#embed_cartridge_post', :via => [:post]
    match 'domain'          => 'legacy_broker#domain_post', :via => [:post]
    match 'userinfo'        => 'legacy_broker#user_info_post', :via => [:post]
    match 'cartlist'        => 'legacy_broker#cart_list_post', :via => [:post]
    match 'ssh_keys'        => 'ssh_keys_post#user_manage_post', :via => [:post]    
  end
end