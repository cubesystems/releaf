Dummy::Application.routes.draw do

  mount_releaf_at '/admin' do
    releaf_resources :books, :authors, :chapters, :publishers
    releaf_resources :banners, only: [:index, :show]
  end
end
