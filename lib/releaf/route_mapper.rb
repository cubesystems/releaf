module Releaf::RouteMapper
  def releaf_resources(*args, &block)
    add_confirm_destroy = true

    if args.last.is_a? Hash
      options = args.last
      if options.has_key? :only
        add_confirm_destroy = false unless options[:only].include? :destroy

        unless options[:only].include? :show
          if options[:only].include? :edit
            options = { :path_names => { :edit => '' } }.deep_merge(options)
          end
        end
      end

      if options.has_key? :except
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
      get   :confirm_destroy, :on => :member      if add_confirm_destroy
    end
  end

  def mount_releaf_at mount_location, options={}, &block
    allowed_controllers = options.try(:[], :allowed_controllers)

    if allowed_controllers.nil? or allowed_controllers.include? :content
      post '/tinymce_assets' => 'releaf/tinymce_assets#create'
    end

    devise_for Releaf.devise_for, :path => mount_location, :controllers => { :sessions => "releaf/sessions" }

    mount_location_namespace = mount_location.gsub("/", "").to_sym
    scope mount_location do
      if mount_location_namespace.empty?
        yield if block_given?
      else
        namespace mount_location_namespace, :path => nil do
          yield if block_given?
        end
      end

      namespace :releaf, :path => nil do
        releaf_resources :admins if (allowed_controllers.nil? or allowed_controllers.include? :admins)
        releaf_resources :roles if (allowed_controllers.nil? or allowed_controllers.include? :roles)

        if allowed_controllers.nil? or allowed_controllers.include? :admins
          get "profile", to: "admin_profile#edit", as: :admin_profile
          put "profile", to: "admin_profile#update", as: :admin_profile
          post "profile/settings", to: "admin_profile#settings", as: :admin_profile_settings
        end

        if allowed_controllers.nil? or allowed_controllers.include? :content
          releaf_resources :nodes, :controller => "content", :path => "content", :except => [:show] do
            get :generate_url, :on => :collection

            get :go_to_dialog, :on => :collection

            member do
              get :copy_dialog
              post :copy

              get :move_dialog
              post :move
            end
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
        get '/*path' => 'base_application#page_not_found'
      end
    end
  end
end # Releaf::RouteMapper
