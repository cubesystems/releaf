module Releaf
  class BuildErrorsHash
    include Releaf::Service
    attribute :resource, Object
    attribute :field_name_prefix, String

    def call
      errors.inject({}) do |h, item|
        field_name = item.delete(:field_name)
        h[field_name] ||= []
        # filter out nested item duplicate errors due to #nested_attribute_errors functionality
        # that returns all errors on each objects
        h[field_name] << item if h[field_name].none?{|error| error == item}
        h
      end
    end

    def errors
      resource.errors.map{|error| format_error(error) }.flatten
    end

    def attribute_error(error)
      {
        field_name: field_name(error.attribute),
        error_code: error.type,
        message: error.message.to_s,
      }
    end

    def format_error(error)
      if resource_attribute?(error.attribute)
        attribute_error(error)
      else
        nested_attribute_errors(error.attribute)
      end
    end

    def nested_attribute_errors(attribute)
      association_name = attribute.to_s.split('.', 2).first
      if single_association?(association_name)
        prefix_template = "#{field_name_prefix}[#{association_name}_attributes]"
        nested_resources = [resource.send(association_name)]
      else
        prefix_template = "#{field_name_prefix}[#{association_name}_attributes][%d]"
        nested_resources = resource.send(association_name)
      end

      nested_resources.each_with_index.map do |nested_resource, i|
        prefix = prefix_template % i
        self.class.new(resource: nested_resource, field_name_prefix: prefix).errors
      end
    end

    def single_association?(association_name)
      [:belongs_to, :has_one].include? association_type(association_name)
    end

    def resource_attribute?(attribute)
      attribute !~ /\./
    end

    def field_name(attribute)
      return field_name_prefix if attribute.to_sym == :base

      field = attribute
      if association(attribute).present?
        field = association(attribute).foreign_key.to_s
      end

      "#{field_name_prefix}[#{field}]"
    end

    def association_type(association_name)
      association(association_name).macro
    end

    def association(association_name)
      resource.class.reflect_on_association(association_name.to_sym)
    end
  end
end
