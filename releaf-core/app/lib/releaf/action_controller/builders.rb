module Releaf::ActionController::Builders
  extend ActiveSupport::Concern

  included do
    helper_method :builder_class, :form_options, :table_options

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

  def form_url(_form_type, object)
    url_for(action: object.new_record? ? 'create' : 'update', id: object.id)
  end

  def form_attributes(_form_type, object, object_name)
    action = object.respond_to?(:persisted?) && object.persisted? ? :edit : :new
    action_object_name = "#{action}-#{object_name}"
    classes = [ action_object_name ]
    classes << "has-error" if object.errors.any?
    {
      multipart: true,
      id: action_object_name,
      class: classes,
      data: {
        "remote" => true,
        "remote-validation" => true,
        "type" => :json,
      },
      novalidate: ''
    }
  end

  def builder_class(builder_type)
    Releaf::Builders.builder_class(builder_scopes, builder_type)
  end

  def application_builder_scope
    [application_scope, "Builders"].reject(&:blank?).join("::")
  end

  def application_scope
    scope = Releaf.application.config.mount_location.capitalize
    scope if scope.present? && Releaf::Builders.constant_defined_at_scope?(scope, Object)
  end

  def builder_scopes
    [self.class.own_builder_scope, self.class.ancestor_builder_scopes, application_builder_scope].flatten
  end

  def form_options(form_type, object, object_name)
    {
      builder: builder_class(:form),
      as: object_name,
      url: form_url(form_type, object),
      html: form_attributes(form_type, object, object_name)
    }
  end

  def table_options
    {
      builder: builder_class(:table),
      toolbox: feature_available?(:toolbox)
    }
  end
end
