require 'awesome_nested_set'
require 'stringex'
require 'deep_cloneable'

module Releaf::Content
  require 'releaf/content/engine'
  require 'releaf/content/configuration'
  require 'releaf/content/router_proxy'
  require 'releaf/content/node_mapper'
  require 'releaf/content/acts_as_node'
  require 'releaf/content/node'
  require 'releaf/content/route'

  # expose configuration wrapper methods as class methods for easier access
  # so that, for example,
  # Releaf::Content.models
  # can be used instead of
  # Releaf::Content.configuration.models
  class << self
    delegate :resources, :models, :default_model, :controllers, :routing, to: :configuration
  end

  def self.configuration
    Releaf.application.config.content
  end

  def self.configure_component
    Releaf.application.config.add_configuration(
      Releaf::Content::Configuration.new(
        resources: { 'Node' => { controller: 'Releaf::Content::NodesController' } }
      )
    )
  end

  def self.initialize_component
    Rails.application.config.middleware.use Releaf::Content::RoutesReloader

    ActiveSupport.on_load :action_controller do
      ActionDispatch::Routing::Mapper.send(:include, Releaf::Content::NodeMapper)
    end
  end

  def self.draw_component_routes(router)
    resources.each do |_model_name, options|
      draw_resource_routes(router, options)
    end
  end

  def self.draw_resource_routes router, options
    route_params = resource_route_params options

    router.releaf_resources(*route_params) do
      router.collection do
        router.get :content_type_dialog
        router.get :generate_url
      end

      router.member do
        router.get :copy_dialog
        router.post :copy
        router.get :move_dialog
        router.post :move
      end
    end
  end

  def self.resource_route_params options
    # Releaf::Content::NodesController -> releaf/content/nodes
    controller_path = options[:controller].constantize.controller_path
    controller_path_parts = controller_path.split('/')

    resources_name = controller_path_parts.last

    route_options = {
      # releaf/content/nodes -> releaf/content
      module: controller_path_parts.slice(0...-1).join('/'),

      # releaf/content/nodes -> releaf_content_nodes
      as: controller_path.gsub(/\//, '_'),

      except: [:show]
    }

    [ resources_name, route_options ]
  end
end
