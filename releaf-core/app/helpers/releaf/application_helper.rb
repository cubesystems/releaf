module Releaf
  module ApplicationHelper
    def merge_attributes(a, b)
      if a.key?(:class) || b.key?(:class)
        classes = {class: [a[:class], b[:class]].flatten.reject(&:blank?)}
      else
        classes = {}
      end

      a.deep_merge(b).merge(classes)
    end

    def releaf_table(collection, resource_class, options = {})
      builder_class = options[:builder]
      options.delete(:builder)
      builder_class.new(collection, resource_class, self, options).output
    end

    def translate(key, options = {})
      # prevent I18n from raising errors when translation is missing
      options.merge!(raise: false) unless options.key?(:raise)
      super(key, options)
    end
    alias :t :translate

    def i18n_options_for_select container, selected, prefix, i18n_options={}
      i18n_options = { scope: controller_scope_name }.merge(i18n_options)

      translated_container = []

      container.each do|element|
        text, value = i18n_option_text_and_value(element).map { |item| item.to_s }
        text = I18n.t("#{prefix}-#{text}", i18n_options.merge(default: text))
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
