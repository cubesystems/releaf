module Releaf::RouteMapper
  # Pass given resource to "resources" mount method and
  # add extra routes for members and collections needed by releaf
  def releaf_resources(*args)
    resources(*args) do
      yield if block_given?
      member do
        get :confirm_destroy if route_enabled?(:destroy, args.last)
        get :toolbox if route_enabled?(:toolbox, args.last)
      end
      collection do
        post :create_releaf_richtext_attachment if route_enabled?(:releaf_richtext_attachments, args.last)
      end
    end
  end

  def initialize_releaf_components
    Releaf.application.config.components.each do|component_class|
      if component_class.respond_to? :draw_component_routes
        component_class.draw_component_routes(self)
      end
    end
  end

  def mount_releaf_at(mount_location)
    mount_location_namespace = mount_location.delete("/").to_sym
    Releaf.application.config.mount_location = mount_location_namespace.to_s
    scope mount_location do
      initialize_releaf_components

      if mount_location_namespace.empty?
        yield if block_given?
      else
        namespace mount_location_namespace, path: nil do
          yield if block_given?
        end
      end

      namespace :releaf, path: nil do
        get '/*path' => 'root#page_not_found'
      end
    end
  end

  private

  def route_enabled?(route, options)
    include_route = true
    if options.is_a? Hash
      if options[:only] && !options[:only].include?(route.to_sym)
        include_route = false
      elsif options[:except].try(:include?, route.to_sym)
        include_route = false
      end
    end

    include_route
  end
end
