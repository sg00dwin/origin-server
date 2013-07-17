Broker::Application.routes.draw do
  match '/broker/nurture' => 'broker#nurture_post', :via => [:post]

  scope "/broker/rest" do
    resource :user, :only => [:show, :update, :destroy], :controller => :user_ext
    resources :plans, :only => [:index, :show]
  end

end
