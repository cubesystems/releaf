LeafRails::Engine.routes.draw do
  root :to => "application#index"
  resources :admins

  resources :nodes, :controller => "content", :path => "content" do
    get :confirm_destroy, :on => :member
  end

  resources :translation_groups, :controller => "aliases", :path => "aliases" do
    get :confirm_destroy, :on => :member
    match :urls, :on => :collection
  end


  scope '/settings' do
    get '',     :to => 'settings#index', :as => 'settings'
    put '',     :to => 'settings#update'
  end

  root :to => 'home#index'


  devise_for :admins, :path => "devise", :controllers => { :sessions => "sessions" }
end
