module Releaf::Builders::Base
  extend ActiveSupport::Concern

  delegate :controller, :controller_name, :url_for, :form_for,
    :releaf_button, :params, :form_tag, :file_field_tag,
    :request, :check_box_tag, :label_tag, :content_tag, :hidden_field_tag,
    :render, :link_to, :flash, :truncate, :toolbox, :radio_button_tag,
    :options_for_select, :action_name, :options_from_collection_for_select,
    :select_tag, :text_field_tag,
    :image_tag, :jquery_date_format, :cookies, :button_tag, :merge_attributes, to: :template

  delegate :layout_settings, :access_control, :controller_scope_name,
    :feature_available?, :index_url, to: :controller

  alias_method :button, :releaf_button

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

  def tag(*args, &block)
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

  def safe_join(&block)
    template.safe_join(yield)
  end

  def t(key, options = {})
    options[:scope] = default_translation_scope unless options.key? :scope
    I18n.t(key, options)
  end

  def default_translation_scope
    controller_scope_name
  end

  # calls `#to_text` on resource if resource supports it. Otherwise calls
  # `#to_s` method
  def resource_to_text(resource)
    resource.send(resource.respond_to?(:to_text) ? :to_text : :to_s)
  end
end
