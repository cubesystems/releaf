require 'releaf/content/acts_as_node/active_record/acts/node'
require 'releaf/content/acts_as_node/action_controller/acts/node'

module ActsAsNode
  @classes = []

  def self.register_class(class_name)
    @classes << class_name unless @classes.include? class_name
  end

  module ClassMethods

    # There are no configuration options yet.
    #
    def acts_as_node(params: nil, fields: nil)
      configuration = {params: params, fields: fields}

      ActsAsNode.register_class(self.name)

      # Store acts_as_node configuration
      cattr_accessor :acts_as_node_configuration
      self.acts_as_node_configuration = configuration
    end
  end

  def self.classes
    # eager load in dev env
    Rails.application.eager_load! if Rails.env.development?

    @classes
  end

  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'acts_as_node.insert' do
        ActiveSupport.on_load :active_record do
          ActsAsNode::Railtie.insert_into_active_record
        end

        ActiveSupport.on_load :action_controller do
          ActsAsNode::Railtie.insert_into_action_controller
        end
      end
    end
  end

  class Railtie
    def self.insert
      insert_into_active_record
      insert_into_action_controller
    end

    def self.insert_into_active_record
      if defined?(ActiveRecord)
        ActiveRecord::Base.send(:include, ActiveRecord::Acts::Node)
      end
    end

    def self.insert_into_action_controller
      if defined?(ActionController)
        ActionController::Base.send(:include, ActionController::Acts::Node)
      end
    end
  end
end

ActsAsNode::Railtie.insert
