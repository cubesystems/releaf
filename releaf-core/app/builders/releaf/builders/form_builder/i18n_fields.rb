module Releaf::Builders::FormBuilder::I18nFields
  def releaf_text_i18n_field(name, input: {}, label: {}, field: {}, options: {})
    options = {field: {type: "text"}}.deep_merge(options)
    input = {class: "text"}.deep_merge(input)
    localized_field(name, :text_field, input: input, label: label, field: field, options: options)
  end

  def releaf_link_i18n_field(name, input: {}, label: {}, field: {}, options: {})
    options = {field: {type: "link"}}.deep_merge(options)
    releaf_text_i18n_field(name, input: input, label: label, field: field, options: options)
  end

  def releaf_textarea_i18n_field(name, input: {}, label: {}, field: {}, options: {})
    input = {
      rows: 5,
      cols: 75,
    }.merge(input)
    options = {field: {type: "textarea"}}.deep_merge(options)
    localized_field(name, :text_area, input: input, label: label, field: field, options: options)
  end

  def releaf_richtext_i18n_field(name, input: {}, label: {}, field: {}, options: {})
    input = richtext_input_attributes(name).merge(input)
    options = richtext_options(name, options)
    releaf_textarea_i18n_field(name, input: input, label: label, field: field, options: options)
  end

  def localized_field(name, field_type, input: {}, label: {}, field: {}, options: {})
    options = {i18n: true, label: {translation_key: name}}.deep_merge(options)

    wrapper(field_attributes(name, field, options)) do
      content = object.class.globalize_locales.collect do |locale|
        localized_name = "#{name}_#{locale}"
        html_class = ["localization"]
        html_class << "active" if locale == default_locale

        tag(:div, class: html_class, data: {locale: locale}) do
          releaf_label(localized_name, label, options) <<
          tag(:div, class: "value") do
            attributes = input_attributes(name, {value: object.send(localized_name)}.merge(input), options)
            send(field_type, localized_name, attributes)
          end
        end
      end

      content << localization_switch
    end
  end

  def localization_switch
    tag(:div, class: "localization-switch") do
      button_tag(type: 'button', title: t('Switch locale'), class: "trigger") do
        tag(:span, default_locale, class: "label") + tag(:i, nil, class: ["fa", "fa-chevron-down"])
      end <<
      tag(:menu, class: ["localization-menu-items"], type: 'toolbar') do
        tag(:ul) do
          object.class.globalize_locales.collect do |locale|
            tag(:li) do
              tag(:button, translate_locale(locale), type: "button", data: {locale: locale})
            end
          end
        end
      end
    end
  end

  def locales
    object.class.globalize_locales
  end

  def default_locale
    selected_locale = (layout_settings("releaf.i18n.locale") || I18n.locale).to_sym
    locales.include?(selected_locale) ? selected_locale : locales.first
  end
end
