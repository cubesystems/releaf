Leaf.setup do |conf|

  # setup main menu
  conf.main_menu = [
    'leaf/content',
    'leaf/translations',
    '*permissions',
  ]

  conf.base_menu = {
    '*permissions' => [
      ['permissions',   %w[leaf/admins leaf/roles]],
    ]
  }

  conf.layout = 'leaf/admin'
  conf.devise_for 'leaf/admin'

end


module ActionDispatch::Routing
  class Mapper
    def mount_leaf_at(mount_location)

      post '/tinymce_assets' => 'leaf/tinymce_assets#create'

      devise_for Leaf.devise_for, :path => mount_location, :controllers => { :sessions => "leaf/sessions" }

      scope mount_location do
        namespace :leaf, :path => nil do

          resources :admins, :roles do
            get :confirm_destroy, :on => :member
            match :urls, :on => :collection
          end

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

