module Releaf
  class ResourceValidator
    attr_reader :errors

    def self.build_validation_errors resource, field_name_prefix="resource"
      validator = new(resource, field_name_prefix)
      validator.errors
    end

    def initialize resource, field_name_prefix
      @resource = resource
      @klass = @resource.class
      @field_name_prefix = field_name_prefix
      @errors = {}
      @error_message_i18n_scope = "activerecord.errors.messages.#{@klass.name.underscore}"
      build_errors
    end

    private

    def build_errors
      @resource.valid?
      @resource.errors.each do |attribute, message|
        if models_attribute? attribute
          add_error attribute, message
        else
          process_nested_resource_errors attribute
        end
      end
    end

    def process_nested_resource_errors attribute
      association_name = attribute.to_s.split('.', 2).first
      if single_association? association_name
        prefix_template = "#{@field_name_prefix}[#{association_name}_attributes]"
        nested_resources = [@resource.send(association_name)]
      else
        prefix_template = "#{@field_name_prefix}[#{association_name}_attributes][%d]"
        nested_resources = @resource.send(association_name)
      end

      nested_resources.each_with_index do |resource, i|
        prefix = prefix_template % i
        resource_errors = ResourceValidator.build_validation_errors(resource, prefix)
        @errors.merge!(resource_errors)
      end
    end

    def models_attribute? attribute
      attribute !~ /\./
    end

    def add_error attribute, message
      @errors[field_id(attribute)] ||= []
      @errors[field_id(attribute)] << {error_code: message.error_code, full_message: I18n.t(message, scope: @error_message_i18n_scope)}
    end

    def field_id attribute
      field = attribute
      if association(attribute).present?
        field = association(attribute).foreign_key.to_s
      end

      "#{@field_name_prefix}[#{field}]"
    end

    def single_association? association_name
      [:belongs_to, :has_one].include? association_type(association_name)
    end

    def association_type association_name
      association(association_name).macro
    end

    def association association_name
      @klass.reflect_on_association(association_name.to_sym)
    end

  end
end
