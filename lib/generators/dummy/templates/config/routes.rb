Dummy::Application.routes.draw do
  mount_releaf_at '/admin' do
    releaf_resources :books, :authors, :chapters
  end

  Releaf::Node::Route.for(Text).each do|route|
    get route.params('texts#show')
  end

  root :to => 'home#index'
end
