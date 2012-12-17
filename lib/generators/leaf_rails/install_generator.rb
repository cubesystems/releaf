module LeafRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def create_initializer_file
        create_file "config/initializers/leaf_rails.rb", <<CONTENT
module ActionDispatch::Routing
  class Mapper
    def mount_leaf_rails_at(mount_location)

      scope mount_location do
        namespace :leaf_rails, :path => nil do
          root :to => "application#index"

          resources :nodes, :controller => "content", :path => "content" do
            get :confirm_destroy, :on => :member
          end

          resources :translation_groups, :controller => "aliases", :path => "aliases" do
            get :confirm_destroy, :on => :member
            match :urls, :on => :collection
          end

          root :to => 'home#index'
        end
      end

      devise_scope mount_location do
        devise_for :admins, :path => "devise", :controllers => { :sessions => "leaf_rails/sessions" }
      end

    end
  end
end
CONTENT
      end
    end
  end
end
