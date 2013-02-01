Releaf.setup do |conf|
  # Default settings are commented out

  ### setup main menu
  # conf.main_menu = [
  #   'releaf/content',
  #   'releaf/translations',
  #   '*permissions',
  # ]

  # conf.base_menu = {
  #   '*permissions' => [
  #     ['permissions',   %w[releaf/admins releaf/roles]],
  #   ]
  # }

  # conf.layout = 'releaf/admin'
  # conf.devise_for 'releaf/admin'

end


module ActionDispatch::Routing
  class Mapper
    def mount_releaf_at(mount_location)

      post '/tinymce_assets' => 'releaf/tinymce_assets#create'

      devise_for Releaf.devise_for, :path => mount_location, :controllers => { :sessions => "releaf/sessions" }

      scope mount_location do
        namespace :releaf, :path => nil do

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

