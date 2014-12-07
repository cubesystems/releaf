module Releaf::Builders::Base
  extend ActiveSupport::Concern

  delegate :controller, :controller_name, :url_for, :feature_available?, :form_for,
    :index_url, :releaf_button, :params, :form_tag, :fa_icon, :file_field_tag,
    :current_admin_user, :request, :check_box_tag, :label_tag, :content_tag, :hidden_field_tag,
    :render, :link_to, :flash, :truncate, :toolbox, :resource_to_text, :radio_button_tag,
    :options_for_select, :action_name, :html_escape, :options_from_collection_for_select,
    :image_tag, :jquery_date_format, :cookies, :button_tag, :merge_attributes, to: :template

  alias_method :button, :releaf_button

  def wrapper(content_or_attributes_with_block, attributes = {}, &block)
    if block_given?
      tag(:div, content_or_attributes_with_block, nil, nil, &block)
    else
      tag(:div, content_or_attributes_with_block, attributes)
    end
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

  def safe_join(&block)
    template.safe_join(yield)
  end

  def t(key, options = {})
    options[:scope] = controller.controller_scope_name unless options.key? :scope
    I18n.t(key, options)
  end
end
