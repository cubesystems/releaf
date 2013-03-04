require 'action_dispatch/routing/mapper'

module ActionDispatch::Routing::Mapper::Resources
  def releaf_resources(*args, &block)
    resources *args do
      yield if block_given?

      add_urls = true
      add_confirm_destroy = true

      if args.last.is_a? Hash
        options = args.last
        if options.has_key? :only
          add_urls            = false unless options[:only].include? :urls
          add_confirm_destroy = false unless options[:only].include? :destroy
        end

        if options.has_key? :except
          add_urls            = false if options[:only].include? :urls
          add_confirm_destroy = false if options[:only].include? :destroy
        end
      end

      match :urls,            :on => :collection  if add_urls
      get   :confirm_destroy, :on => :member      if add_confirm_destroy
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

    if args.last.is_a? Hash

      options = new_resources.pop

      if options.has_key? :only
        add_routes.each_key do |key|
          add_routes[key] = false unless options[:only].include? key
        end
      end

      if options.has_key? :except
        add_routes.each_key do |key|
          add_routes[key] = false if options[:only].include? key
        end
      end

    end

    new_resources.each do |resource_name|
      res_name = resource_name.to_s
      get     res_name,                  :to => "#{res_name}#index",       :as => res_name                          if add_routes[:index]
      post    res_name,                  :to => "#{res_name}#create"                                                     if add_routes[:create]
      get     "#{res_name}/new",         :to => "#{res_name}#new",         :as => "new_#{res_name.singularize}"     if add_routes[:new]
      yield if block_given?
      get     "#{res_name}/*slug/edit",  :to => "#{res_name}#edit",        :as => "edit_#{res_name.singularize}"    if add_routes[:edit]
      get     "#{res_name}/*slug",       :to => "#{res_name}#show",        :as => "show_#{res_name.singularize}"    if add_routes[:show]
      put     "#{res_name}/*slug",       :to => "#{res_name}#update"                                                     if add_routes[:update]
      post    "#{res_name}/*slug",       :to => "#{res_name}#create"                                                     if add_routes[:create]
      delete  "#{res_name}/*slug",       :to => "#{res_name}#destroy"                                                    if add_routes[:destroy]
    end

  end
end
