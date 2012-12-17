class InitializerGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/leaf_rails.rb", <<CONTENT
module ActionDispatch::Routing
  class Mapper
    def mount_my_engine_at(mount_location)

      scope mount_location do
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
      end

      devise_scope mount_location do
        devise_for :admins, :path => "devise", :controllers => { :sessions => "sessions" }
      end

    end
  end
end
CONTENT
  end
end
