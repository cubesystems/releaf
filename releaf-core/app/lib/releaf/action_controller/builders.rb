module Releaf::ActionController::Builders
  extend ActiveSupport::Concern

  included do
    helper_method :builder_class

    def self.own_builder_scope
      name.gsub(/Controller$/, "")
    end

    def self.ancestor_controllers
      # return all ancestor controllers up to but not including Releaf::ActionController
      ancestor_classes = ancestors - included_modules
      ancestor_classes.slice( 0...ancestor_classes.index(Releaf::ActionController) ) - [ self ]
    end

    def self.ancestor_builder_scopes
      ancestor_controllers.map(&:own_builder_scope)
    end
  end

  def builder_class(builder_type)
    Releaf::Builders.builder_class(builder_scopes, builder_type)
  end

  def application_scope
    scope = Releaf.application.config.mount_location.capitalize
    scope if scope.present? && Releaf::Builders.constant_defined_at_scope?(scope, Object)
  end

  def builder_scopes
    [self.class.own_builder_scope, self.class.ancestor_builder_scopes, application_scope].flatten.compact
  end
end
