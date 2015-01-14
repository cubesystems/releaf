module Releaf
  module TemplateFieldTypeMapper

    # Helps to determinate which template to render in :edit feature
    # for given objects attribute.
    #
    # @return field_type
    #
    # where field_type is a string representing field type
    # and use_i18n is a `true` or `false`. If use_i18n is true, then template
    # with localization features should be used (if exists)
    #
    # This helper is used by views.
    #
    # @todo document rendering conventions
    def self.field_type_name obj, attribute_name
      field_type = nil
      column_type = nil

      if use_i18n?(obj, attribute_name)
        begin
          column_type = obj.class::Translation.columns_hash[attribute_name.to_s].try(:type)
        rescue
        end
      else
        column_type = obj.class.columns_hash[attribute_name.to_s].try(:type)
      end

      column_type ||= 'string'

      if respond_to?("field_type_name_for_#{column_type}")
        field_type = send("field_type_name_for_#{column_type}", attribute_name, obj)
      end

      return field_type || 'text'
    end

    # should localized template be preffered?
    def self.use_i18n? obj, attribute_name
      return false unless obj.class.respond_to? :translates?
      return false unless obj.class.translates?
      return obj.class.translated_attribute_names.include?(attribute_name.to_sym)
    end

    protected

    def self.image_or_error attribute_name, obj
      field_type_or_error 'image', attribute_name, obj
    end

    def self.file_or_error attribute_name, obj
      field_type_or_error 'file', attribute_name, obj
    end

    def self.field_type_or_error type, attribute_name, obj
      raise ArgumentError, 'attribute_name must end with _uid' unless attribute_name =~ /_uid$/
      file_method_name = attribute_name.to_s.sub(/_uid$/, '')
      if obj.respond_to? file_method_name
        return type
      else
        raise "object doesn't respond to `#{file_method_name}` method. Did you forgot to add `#{type}_accessor :#{file_method_name}` to `#{obj.class.name}` model?"
      end
    end

    def self.field_type_name_for_string attribute_name, obj
      case attribute_name.to_s
      when /(thumbnail|image|photo(graphy)?|picture|avatar|logo|banner|icon)_uid$/
        return image_or_error attribute_name, obj

      when /_uid$/
        return file_or_error attribute_name, obj

      when /password/, 'pin'
        return 'password'

      when /_email$/, 'email'
        return 'email'

      when /_link$/, 'link'
        return 'link'

      else
        return 'text'
      end
    end

    def self.field_type_name_for_text attribute_name, obj
      case attribute_name.to_s
      when /_(url|homepage|link)$/, 'homepage', 'url'
        'link'
      when /_html$/, 'html'
        'richtext'
      else
        'textarea'
      end
    end

    def self.field_type_name_for_datetime attribute_name, obj
      'datetime'
    end

    def self.field_type_name_for_date attribute_name, obj
      'date'
    end

    def self.field_type_name_for_time attribute_name, obj
      'time'
    end

    def self.field_type_name_for_integer attribute_name, obj
      return 'item' if attribute_name.to_s =~ /_id$/ && obj.class.reflect_on_association(attribute_name[0..-4].to_sym)
      return 'text'
    end

    def self.field_type_name_for_boolean attribute_name, obj
      return 'boolean'
    end

  end
end
