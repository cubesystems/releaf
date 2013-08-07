module Releaf
  module ApplicationHelper
    def i18n_options_for_select container, selected, prefix, i18n_options={}
      i18n_options = { scope: controller_scope_name }.merge(i18n_options)

      translated_array = []

      if container.is_a? Hash
        container.each_pair do |key, hash_value|
          text = I18n.t("#{prefix.to_s}-#{hash_value.to_s}", i18n_options.merge(default: hash_value.to_s))
          value = hash_value.respond_to?(:id) ? hash_value.id : key.to_s
          translated_array << [text, value]
        end
      elsif container.is_a? Array
        container.each do |item|
          text = I18n.t("#{prefix.to_s}-#{item.to_s}", i18n_options.merge(default: item.to_s))
          value = item.respond_to?(:id) ? item.id : item.to_s
          translated_array << [text, value]
        end
      else
        raise ArgumentError, "unsupported container class: #{container.class.name}"
      end

      return options_for_select(translated_array, selected)
    end

  end
end
