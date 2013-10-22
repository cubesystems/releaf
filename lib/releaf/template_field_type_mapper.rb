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
      column_type = nil # column_type == nil means Virtual column

      if use_i18n?(obj, attribute_name)
        begin
          column_type = obj.class::Translation.columns_hash[attribute_name.to_s].try(:type)
        rescue
        end
      else
        column_type = obj.class.columns_hash[attribute_name.to_s].try(:type)
      end

      if column_type.nil?
        if attribute_name.to_s =~ /^#{Releaf::Node::COMMON_FIELD_NAME_PREFIX}/
          column_type = obj.common_field_field_type(attribute_name)
        end
      end

      column_type = column_type.to_s
      if column_type && self.respond_to?("field_type_name_for_#{column_type}")
        field_type = self.send("field_type_name_for_#{column_type}", obj, attribute_name)
      else
        field_type = self.field_type_name_for_virtual obj, attribute_name
      end

      return field_type || 'text'
    end

    # should localized template be preffered?
    def self.use_i18n? obj, attribute_name
      return false unless obj.class.respond_to?(:translations_table_name)
      return obj.class.translates.include?(attribute_name.to_sym)
    end

    protected

    def self.field_type_name_for_string obj, attribute_name
      case attribute_name.to_s
      when /(thumbnail|image|photo(graphy)?|picture|avatar|logo|banner|icon)_uid$/
        return 'image'

      when /_uid$/
        return 'file'

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

    def self.field_type_name_for_virtual obj, attribute_name
      case attribute_name.to_s
      when /(thumbnail|image|photo(graphy)?|picture|avatar|logo|banner|icon)_uid$/
        return 'image'

      when /_id$/
        return 'item' if obj.class.reflect_on_association(attribute_name[0..-4].to_sym)
        return 'text'

      when /_uid$/
        return 'file'

      when /password/, 'pin'
        return 'password'

      when /_email$/, 'email'
        return 'email'

      when /_link$/, 'link'
        return 'link'

      when /_(url|homepage)$/, 'homepage', 'url'
        return 'url'

      when /_link$/
        return 'link_or_url'

      when /_(text|description)$/, 'text', 'description'
        return 'textarea'

      when /_html$/, 'html'
        return 'richtext'

      when /_(date|on)$/, 'date'
        return 'date'

      when /_time$/, 'time'
        return 'time'

      when /_at$/
        return 'datetime'

      else
        return 'text'
      end
    end

    def self.field_type_name_for_boolean obj, attribute_name
      return 'boolean'
    end

  end
end