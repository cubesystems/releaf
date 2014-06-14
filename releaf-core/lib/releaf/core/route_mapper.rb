module Releaf::Core::RouteMapper
  # Pass given resource to "resources" mount method and
  # add extra routes for members and collections needed by releaf
  def releaf_resources(*args, &block)
    resources *args do
      yield if block_given?
      get   :confirm_destroy, :on => :member      if include_confirm_destroy?(args.last)
      get   :toolbox, :on => :member              if include_toolbox?(args.last)
    end
  end

  def initialize_releaf_components
    Releaf.components.each do|component_class|
      if component_class.respond_to? :draw_component_routes
        component_class.draw_component_routes(self)
      end
    end
  end

  def mount_releaf_at mount_location, options={}, &block
    devise_for Releaf.devise_for, path: mount_location, controllers: { sessions: "releaf/sessions" }

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
        initialize_releaf_components

        root :to => "home#index"
        get '/*path' => 'home#page_not_found'
      end
    end
  end

  private

  # Check whether add confirm destroy route
  def include_confirm_destroy? options
    return include_routes? :destroy, options
  end

  def include_toolbox? options
    return include_routes? :toolbox, options
  end

  def include_routes? route, options
    include_route = true
    if options.is_a? Hash
      if options[:only] && !options[:only].include?(route.to_sym)
        include_route = false
      elsif options[:except].try(:include?, route.to_sym)
        include_route = false
      end
    end

    return include_route
  end
end # Releaf::RouteMapper
