Leaf.setup do |conf|

  # setup main menu
  conf.main_menu = [
    'leaf/content',
    'leaf/translations',
    '*permissions',
  ]

  conf.base_menu = {
    '*permissions' => [
      ['permissions',   %w[admin/admins admin/roles]],
    ]
  }

  conf.tinymce_assets_path = 'private/tinymce_assets'

end


module ActionDispatch::Routing
  class Mapper
    def mount_leaf_at(mount_location)

      post '/tinymce_assets' => 'leaf/tinymce_assets#create'
      get '/tinymce_assets/:id' => 'leaf/tinymce_assets#serve', :as => 'serve_tinymce_asset'

      devise_for :admins, :path => mount_location, :controllers => { :sessions => "leaf/sessions" }

      scope mount_location do
        namespace :leaf, :path => nil do

          resources :nodes, :controller => "content", :path => "content" do
            member do
              get :confirm_destroy
              get :get_content_form
            end

            get :generate_url, :on => :collection
          end

          resources :translation_groups, :controller => "translations", :path => "translations" do
            get :confirm_destroy, :on => :member
            match :urls, :on => :collection
          end
          root :to => "content#index"
        end
      end

    end
  end
end

