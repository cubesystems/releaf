module Releaf::Permissions
  class Configuration
    include Virtus.model(strict: true)
    attribute :devise_for, String
    attribute :access_control, Object
    attribute :permanent_allowed_controllers, Array

    def devise_model_name
      devise_for.gsub("/", "_")
    end

    def devise_model_class
      devise_for.classify.constantize
    end

    def self.component_configuration
      new(
        devise_for: "releaf/permissions/user",
        access_control: Releaf::Permissions::AccessControl,
        permanent_allowed_controllers: ['releaf/core/root', 'releaf/core/errors']
      )
    end
  end
end
