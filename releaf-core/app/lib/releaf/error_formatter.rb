module Releaf
  class ErrorFormatter
    attr_reader :errors

    def self.format_errors resource, field_name_prefix="resource"
      validator = new(resource, field_name_prefix)
      validator.errors
    end

    def initialize resource, field_name_prefix
      @resource = resource
      @klass = @resource.class
      @field_name_prefix = field_name_prefix
      @errors = {}
      @error_message_i18n_scope = "activerecord.errors.messages.#{@klass.name.underscore}"
      format_errors
    end

    private

    def format_errors
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
        resource_errors = ErrorFormatter.format_errors(resource, prefix)
        @errors.merge!(resource_errors)
      end
    end

    def models_attribute? attribute
      attribute !~ /\./
    end

    def add_error attribute, message
      @errors[field_id(attribute)] ||= []
      @errors[field_id(attribute)] << error_hash(attribute, message)
    end

    def error_hash attribute, message
      h = {
        error_code: message.error_code,
        message: I18n.t(message, scope: @error_message_i18n_scope),
        full_message: full_error_message(attribute, message)
      }
      h[:data] = message.data unless message.data.nil?
      h
    end

    def full_error_message(attribute, message)
      template = "%{class} with id %{id} has error \"#{message}\""
      template += ' on attribute "%{attribute}"' unless attribute.to_sym == :base
      options = {
        default: template,
        attribute: attribute,
        class: @resource.class.name,
        id: @resource.id ? @resource.id.to_s : 'null',
        scope: @error_message_i18n_scope
      }
      I18n.t(template, options)
    end

    def field_id attribute
      return @field_name_prefix if attribute.to_sym == :base
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
