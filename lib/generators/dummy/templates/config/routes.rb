Dummy::Application.routes.draw do
  mount_releaf_at '/admin'

  namespace :admin do
    releaf_resources :admins, :roles, :books, :authors
  end

  root :to => 'home#index'

end
