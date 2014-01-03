module Releaf
  module ResourceValidator


    def self.build_validation_errors resource, error_scope_name
      errors = {}

      resource.errors.each do |attribute, message|
        field_id = validation_attribute_field_id resource, attribute
        unless errors.has_key? attribute
          errors[field_id] = []
        end

        errors[field_id] << {error_code: message.error_code, full_message: I18n.t(message, scope: 'validation.' + error_scope_name)}
      end

      return errors
    end

    protected

    def self.validation_attribute_name resource, attribute, check_relations=false
      return attribute.to_s if resource.attributes.include? attribute.to_s
      return resource.class.reflections[attribute.to_sym].foreign_key.to_s if check_relations && resource.class.reflections[attribute.to_sym].present?
      return attribute.to_s if resource.respond_to? attribute
      return nil
    end

    def self.validation_attribute_field_id resource, attribute
      parts = attribute.to_s.split('.')
      prefix = "resource"

      if parts.length > 1
        field_name = validation_attribute_nested_field_name(resource, parts)
      else
        attribute = validation_attribute_name resource, parts[0], true
        if attribute
          field_name = "["
          field_name += attribute
          # normalize field id for globalize3 attributes without prefix
          if resource.class.translates? && resource.class.translated_attribute_names.include?(attribute.to_sym)
            field_name += "_#{I18n.default_locale}"
          end

          field_name += "]"
        else
          field_name = ''
        end
      end

      field_name = prefix + field_name

      return field_name
    end

    def self.validation_attribute_nested_field_name resource, parts
      attribute = parts[0]

      association_type = resource.class.reflect_on_association(attribute.to_sym).macro
      if association_type == :belongs_to
        nested_items = [resource.send(attribute)]
      else
        nested_items = resource.send(attribute)
      end

      nested_items.each_with_index do |item, index|
        unless item.valid?
          if association_type == :belongs_to
            attribute_name = validation_attribute_name(item, parts[1], true)
            if attribute_name
              field_id = "[" + attribute + "_attributes][#{ attribute_name }]"
            else
              field_id = ''
            end
          else
            field_id = "[" + attribute + "_attributes][#{index}]"
            if parts.length == 2
              field_id += "[" + parts[1] + "]"
            else
              field_id += validation_attribute_nested_field_name(item, parts[1..-1])
            end
          end

          return field_id
        end
      end
    end


  end
end
