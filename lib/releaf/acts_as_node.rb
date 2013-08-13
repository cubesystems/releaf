require 'releaf/acts_as_node/active_record/acts/node'

module ActsAsNode
  @classes = []

  def self.register_class(class_name)
    @classes << class_name
  end

  def self.classes
    @classes
  end

  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'acts_as_node.insert_into_active_record' do
        ActiveSupport.on_load :active_record do
          ActsAsNode::Railtie.insert
        end
      end
    end
  end

  class Railtie
    def self.insert
      if defined?(ActiveRecord)
        ActiveRecord::Base.send(:include, ActiveRecord::Acts::Node)
      end
    end
  end
end

ActsAsNode::Railtie.insert
