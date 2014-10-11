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
      return column_type(obj, attribute_name) || fallback(obj, attribute_name)
    end

    # should localized template be preffered?
    def self.use_i18n? obj, attribute_name
      return false unless obj.class.respond_to? :translates?
      return false unless obj.class.translates?
      return obj.class.translated_attribute_names.include?(attribute_name.to_sym)
    end

    def self.column_type obj, attribute_name
      column_type = nil

      if use_i18n?(obj, attribute_name)
        begin
          column_type = obj.class::Translation.columns_hash[attribute_name.to_s].try(:type).try(:to_s)
        rescue
        end
      else
        column_type = obj.class.columns_hash[attribute_name.to_s].try(:type).try(:to_s)
      end

      if column_type.present? && self.respond_to?("field_type_name_for_#{column_type}")
        return self.send("field_type_name_for_#{column_type}", obj, attribute_name)
      else
        return nil
      end
    end

    protected

    def self.fallback obj, attribute_name
      case attribute_name.to_s
      when /password/, 'pin'
        return 'password'
      else
        return 'text'
      end
    end

    def self.image_or_error obj, attribute_name
      field_type_or_error 'image', obj, attribute_name
    end

    def self.file_or_error obj, attribute_name
      field_type_or_error 'file', obj, attribute_name
    end

    def self.field_type_or_error type, obj, attribute_name
      raise ArgumentError, 'attribute_name must end with _uid' unless attribute_name =~ /_uid$/
      file_method_name = attribute_name.to_s.sub(/_uid$/, '')
      if obj.respond_to? file_method_name
        return type
      else
        raise "object doesn't respond to `#{file_method_name}` method. Did you forgot to add `#{type}_accessor :#{file_method_name}` to `#{obj.class.name}` model?"
      end
    end

    def self.field_type_name_for_string obj, attribute_name
      case attribute_name.to_s
      when /(thumbnail|image|photo(graphy)?|picture|avatar|logo|banner|icon)_uid$/
        return image_or_error obj, attribute_name

      when /_uid$/
        return file_or_error obj, attribute_name

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

    def self.field_type_name_for_text obj, attribute_name
      case attribute_name.to_s
      when /_(url|homepage)$/, 'homepage', 'url'
        return 'url'

      when /_link$/
        return 'link_or_url'

      when /_html$/, 'html'
        return 'richtext'

      else
        return 'textarea'
      end
    end

    def self.field_type_name_for_datetime obj, attribute_name
      'datetime'
    end

    def self.field_type_name_for_date obj, attribute_name
      'date'
    end

    def self.field_type_name_for_time obj, attribute_name
      'time'
    end

    def self.field_type_name_for_integer obj, attribute_name
      return 'item' if attribute_name.to_s =~ /_id$/ && obj.class.reflect_on_association(attribute_name[0..-4].to_sym)
      return 'text'
    end

    def self.field_type_name_for_boolean obj, attribute_name
      return 'boolean'
    end

  end
end
