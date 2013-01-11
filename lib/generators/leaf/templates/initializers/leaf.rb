Leaf.setup do |conf|

  # setup main menu
  conf.main_menu = [
    'leaf/content',
    '*modules',
    'leaf/aliases'
  ]

  conf.alt_menu = {
    '*modules' => [
      ['shop',          %w[admin/catalog admin/shipping_addresses admin/product_requests admin/discount_levels admin/manufacturers]],
      ['clients',       %w[admin/users admin/orders]],
      ['other',         %w[admin/news_articles admin/colors admin/colors admin/countries admin/currencies admin/email_messages admin/messages admin/settings]],
      ['permissions',   %w[admin/admins admin/roles]],
    ]
  }

end



module ActionDispatch::Routing
  class Mapper
    def mount_leaf_at(mount_location)
      devise_for :admins, :path => mount_location, :controllers => { :sessions => "leaf/sessions" }

      scope mount_location do
        namespace :leaf, :path => nil do
          root :to => "application#index"

          resources :nodes, :controller => "content", :path => "content" do
            get :confirm_destroy, :on => :member
            get :get_content_form, :on => :member
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
