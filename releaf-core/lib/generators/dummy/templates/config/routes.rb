Dummy::Application.routes.draw do
  mount_releaf_at '/admin' do
    releaf_resources :books, :authors, :chapters
  end

  Releaf::ContentRoute.for(Text).each do|route|
    get route.params('texts#show')
  end

  Releaf::ContentRoute.for(ContactsController).each do|route|
    get route.params('contacts#show')
  end

  root :to => 'home#index'
end
