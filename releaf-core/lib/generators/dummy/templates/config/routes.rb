Dummy::Application.routes.draw do
  mount_releaf_at '/admin' do
    releaf_resources :books, :authors, :chapters, :publishers
  end

  releaf_routes_for(HomePage) do
    get 'show'
  end

  releaf_routes_for(TextPage) do
    get 'show'
  end

  releaf_routes_for(ContactsController) do
    get 'show'
  end

  root to: 'application#redirect_to_locale_root'
end
