module Releaf
  module ApplicationHelper
    def i18n_options_for_select container, selected, prefix, i18n_options={}
      i18n_options = { scope: controller_scope_name }.merge(i18n_options)

      translated_container = []

      container.each do|element|
        text, value = i18n_option_text_and_value(element).map { |item| item.to_s }
        text = I18n.t("#{prefix.to_s}-#{text}", i18n_options.merge(default: text))
        translated_container << [text, value]
      end

      return options_for_select(translated_container, selected)
    end

    private
      def i18n_option_text_and_value(option)
        # Options are [text, value] pairs or strings used for both.
        if !option.is_a?(String) && option.respond_to?(:first) && option.respond_to?(:last)
          option = option.reject { |e| Hash === e } if Array === option
          [option.first, option.last]
        else
          [option, option]
        end
      end
  end
end
