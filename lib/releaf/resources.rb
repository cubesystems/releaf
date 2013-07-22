require 'action_dispatch/routing/mapper'

module ActionDispatch::Routing
  class Mapper

    def releaf_resources(*args, &block)
      add_urls = true
      add_confirm_destroy = true

      if args.last.is_a? Hash
        options = args.last
        if options.has_key? :only
          add_urls            = false unless options[:only].include? :urls
          add_confirm_destroy = false unless options[:only].include? :destroy

          unless options[:only].include? :show
            if options[:only].include? :edit
              options = { :path_names => { :edit => '' } }.deep_merge(options)
            end
          end
        end

        if options.has_key? :except
          add_urls            = false if options[:except].include? :urls
          add_confirm_destroy = false if options[:except].include? :destroy

          if options[:except].include? :show
            unless options[:except].include? :edit
              options = { :path_names => { :edit => '' } }.deep_merge(options)
            end
          end
        end
        args[-1] = options

      end

      resources *args do
        yield if block_given?

        match :urls,            :on => :collection  if add_urls
        get   :confirm_destroy, :on => :member      if add_confirm_destroy
        post  :validate,        :on => :new
        put   :validate,        :on => :member
      end
    end

    def slugged_resources(*args, &block)
      add_routes = {
        :new      => true,
        :create   => true,
        :edit     => true,
        :update   => true,
        :show     => true,
        :index    => true,
        :destroy  => true
      }

      new_resources = args

      edit_instead_of_show = false

      if args.last.is_a? Hash

        options = args.pop

        if options.has_key? :only
          add_routes.each_key do |key|
            add_routes[key] = false unless options[:only].include? key
          end

          unless options[:only].include? :show
            if options[:only].include? :edit
              edit_instead_of_show = true
            end
          end
        end

        if options.has_key? :except
          add_routes.each_key do |key|
            add_routes[key] = false if options[:except].include? key
          end

          if options[:except].include? :show
            unless options[:except].include? :edit
              edit_instead_of_show = true
            end
          end
        end
      end

      new_resources.each do |resource_name|
        res_name = resource_name.to_s
        get     res_name,                   :to => "#{res_name}#index",       :as => res_name                          if add_routes[:index]
        post    res_name,                   :to => "#{res_name}#create"                                                if add_routes[:create]
        get     "#{res_name}/new",          :to => "#{res_name}#new",         :as => "new_#{res_name.singularize}"     if add_routes[:new]
        yield if block_given?
        if edit_instead_of_show
          get     "#{res_name}/*slug",      :to => "#{res_name}#edit",        :as => "edit_#{res_name.singularize}"    if add_routes[:edit]
        else
          get     "#{res_name}/*slug/edit", :to => "#{res_name}#edit",        :as => "edit_#{res_name.singularize}"    if add_routes[:edit]
          get     "#{res_name}/*slug",      :to => "#{res_name}#show",        :as => "show_#{res_name.singularize}"    if add_routes[:show]
        end
        put     "#{res_name}/*slug",        :to => "#{res_name}#update"                                                if add_routes[:update]
        post    "#{res_name}/*slug",        :to => "#{res_name}#create"                                                if add_routes[:create]
        delete  "#{res_name}/*slug",        :to => "#{res_name}#destroy"                                               if add_routes[:destroy]
      end

    end

    def mount_releaf_at mount_location, options={}
      allowed_controllers = options.try(:[], :allowed_controllers)

      if allowed_controllers.nil? or allowed_controllers.include? :content
        post '/tinymce_assets' => 'releaf/tinymce_assets#create'
      end

      devise_for Releaf.devise_for, :path => mount_location, :controllers => { :sessions => "releaf/sessions" }

      scope mount_location do

        namespace :releaf, :path => nil do

          releaf_resources :admins if (allowed_controllers.nil? or allowed_controllers.include? :admins)
          releaf_resources :roles if (allowed_controllers.nil? or allowed_controllers.include? :roles)

          if allowed_controllers.nil? or allowed_controllers.include? :admins
            get "profile", to: "admin_profile#edit", as: :admin_profile
            put "profile", to: "admin_profile#update", as: :admin_profile
            put "profile/validate", to: "admin_profile#validate", as: :admin_profile_validate
          end

          if allowed_controllers.nil? or allowed_controllers.include? :content
            releaf_resources :nodes, :controller => "content", :path => "content", :except => [:show] do
              get :generate_url, :on => :collection
            end
          end

          if allowed_controllers.nil? or allowed_controllers.include? :translations
            releaf_resources :translation_groups, :controller => "translations", :path => "translations", :except => [:show] do
              member do
                get :export
                post :import
              end
            end
          end

          root :to => "home#index"
        end
      end
    end


  end # class Mapper
end # module ActionDispatch::Routing
