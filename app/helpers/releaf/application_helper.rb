module Releaf
  module ApplicationHelper
    def i18n_options_for_select container, selected, prefix, i18n_options={}
      i18n_options = { :scope => controller_scope_name }.merge(i18n_options)

      translated_array = []

      if container.is_a? Hash

        hash.each_pair do |key, value|
          translated_item = I18n.t("#{prefix.to_s}-#{value.to_s}", i18n_options.merge(:default => key.to_s))
          translated_array += [translated_item, value]
        end

      elsif container.is_a? Array
        if container.first.respond_to?(:id)
          translated_array = container.map do |item|
            translated_item = [
              I18n.t("#{prefix.to_s}-#{item.respond_to?(:to_text) ? item.to_text : item.to_s}", i18n_options.merge(:default => item.respond_to?(:to_text) ? item.to_text : item.to_s)),
              item.id
            ]
          end

        else
          translated_array = container.map do |item|
            translated_item = I18n.t("#{prefix.to_s}-#{item.respond_to?(:to_text) ? item.to_text : item.to_s}", i18n_options.merge(:default => item.respond_to?(:to_text) ? item.to_text : item.to_s))
          end
        end
      else
        raise ArgumentError, "unsupported container: #{container.class.name}"
      end

      return translated_array
    end

  end
end
