module Releaf::Builders::Base
  extend ActiveSupport::Concern

  delegate :controller, :controller_name, :url_for, :form_for,
    :releaf_button, :params, :form_tag, :file_field_tag,
    :request, :check_box_tag, :label_tag, :content_tag, :hidden_field_tag,
    :render, :link_to, :flash, :truncate, :radio_button_tag,
    :options_for_select, :action_name, :options_from_collection_for_select,
    :select_tag, :text_field_tag,
    :image_tag, :cookies, :button_tag, :merge_attributes, to: :template

  delegate :controller_scope_name, :builder_class,
    :feature_available?, :index_path, to: :controller

  alias_method :button, :releaf_button

  def layout_settings(key)
    Releaf.application.config.settings_manager.read(controller: controller, key: key)
  end

  def wrapper(content_or_attributes_with_block, attributes = {}, &block)
    if block_given?
      tag(:div, content_or_attributes_with_block, nil, nil, &block)
    else
      tag(:div, content_or_attributes_with_block, attributes)
    end
  end

  def html_escape(value)
    ERB::Util.html_escape(value)
  end

  def tag(*args)
    return content_tag(*args) unless block_given?

    content_tag(*args) do
      block_result = yield
      if block_result.is_a? Array
        safe_join do
          block_result
        end
      else
        block_result.to_s
      end
    end
  end

  def template_variable(variable)
    template.instance_variable_get("@#{variable}")
  end

  def icon(name)
    template.fa_icon(name)
  end

  def safe_join
    template.safe_join(yield)
  end

  def t(key, options = {})
    options[:scope] = default_translation_scope unless options.key? :scope
    I18n.t(key, options)
  end

  def translate_locale(locale)
    t(locale, scope: "locales")
  end

  def locale_options(locales)
    locales.collect do|locale|
      [translate_locale(locale), locale]
    end
  end

  def default_translation_scope
    controller_scope_name
  end

  def resource_title(resource)
    Releaf::ResourceBase.title(resource)
  end
end
