Dummy::Application.routes.draw do
  mount_releaf_at '/admin' do
    releaf_resources :books, :authors
  end

  root :to => 'home#index'
end
