Rails.application.routes.draw do
  scope 'console' do
    openshift_console
  end

  root :to => app_redirect('console')
end
