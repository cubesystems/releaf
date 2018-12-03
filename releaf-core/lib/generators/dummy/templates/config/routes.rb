Dummy::Application.routes.draw do

  mount_releaf_at '/admin' do
    releaf_resources :books, :authors, :chapters, :publishers
    releaf_resources :banners, only: [:index, :show]
  end

  # SINGLE NODE CLASS CASE:

  # node_routes_for(HomePage) do
    # get 'show', as: "home_page"
  # end


  # MULTIPLE NODE CLASSES CASE:

  # automatic hostname constraints for all defined nodes/sites:
  node_routing( Releaf::Content.routing ) do

    node_routes_for(HomePage) do
      get 'show', as: "home_page"
    end

    node_routes_for(TextPage) do
      get 'show'
    end

  end

  # manual hostname constraint blocks for nodes specific to a single site:
  constraints Releaf::Content.routing['Node'][:constraints] do

    # contacts page route will be only on main site
    node_routes_for(ContactsController, node_class: 'Node') do
      get 'show', as: "contacts_page"
    end

  end

  root to: 'application#redirect_to_locale_root'

  match "*not_found_path", to: "application#render_404", via: [:get, :post], format: false

end
