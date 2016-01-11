module Releaf::Content
  class Configuration

    def resources
      @resources ||= verify_config( Releaf.application.config.content_resources )
    end

    def verify_config resource_config
      # perform some basic config structure validation
      unless resource_config.is_a? Hash
        raise Releaf::Core::Error, "Releaf.application.config.content_resources must be a Hash"
      end

      resource_config.each do | key, values |
        unless key.is_a? String
          raise Releaf::Core::Error, "Releaf.application.config.content_resources must have string keys"
        end
        unless values.is_a? Hash
          raise Releaf::Core::Error, "#{key} in Releaf.application.config.content_resources must have a hash value"
        end
        unless values[:controller].is_a? String
          raise Releaf::Core::Error, "#{key} in Releaf.application.config.content_resources must have controller class specified as a string"
        end
      end

      resource_config
    end

    def models
      @models ||= resources.keys.map(&:constantize)
    end

    def default_model
      models.first
    end

    def controllers
      @controllers ||= resources.values.map { |options| options[:controller].constantize }
    end

    def routing
      @routing ||= resources.map do | node_class_name, options |
        routing = options[:routing] || {}
        routing[:site]        ||= nil
        routing[:constraints] ||= nil
        [ node_class_name, routing ]
      end.to_h
    end

  end

end
