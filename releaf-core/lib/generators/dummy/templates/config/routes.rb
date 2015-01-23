Dummy::Application.routes.draw do
  mount_releaf_at '/admin' do
    releaf_resources :books, :authors, :chapters
  end

  Releaf::Content::Route.for(TextPage).each do|route|
    get route.params('text_pages#show')
  end

  Releaf::Content::Route.for(ContactsController).each do|route|
    get route.params('contacts#show')
  end

  root :to => 'home#index'
end
