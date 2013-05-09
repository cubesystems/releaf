module Releaf
  module ApplicationHelper
    def i18n_options_for_select container, selected, prefix, i18n_options={}
      i18n_options = { :scope => controller_scope_name }.merge(i18n_options)

      if container.is_a? Hash
        translated_array = []

        hash.each_pair do |key, value|
          translated_item = I18n.t("#{prefix.to_s}-#{value.to_s}", i18n_options.merge(:default => key.to_s))
          [translated_item, value]
        end

        return translated_array

      elsif container.is_a? Array
        translated_array = container.map do |item|
          translated_item = I18n.t("#{prefix.to_s}-#{item.to_s}", i18n_options.merge(:default => item.to_s))
          [translated_item, item.to_s]
        end
        return translated_array
      else
        raise ArgumentError, "unsupported container: #{container.class.name}"
      end
    end

  end
end
