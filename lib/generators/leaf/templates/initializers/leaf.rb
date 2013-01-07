module ActionDispatch::Routing
  class Mapper
    def mount_leaf_at(mount_location)
      devise_for :admins, :path => mount_location, :controllers => { :sessions => "leaf/sessions" }

      scope mount_location do
        namespace :leaf, :path => nil do
          root :to => "application#index"

          resources :nodes, :controller => "content", :path => "content" do
            get :confirm_destroy, :on => :member
          end

          resources :translation_groups, :controller => "aliases", :path => "aliases" do
            get :confirm_destroy, :on => :member
            match :urls, :on => :collection
          end
        end
      end

    end
  end
end
