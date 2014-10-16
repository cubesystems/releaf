module Releaf::Builder
  extend ActiveSupport::Concern

  def resource_class_attributes(resource_class)
    resource_class.column_names + resource_class_i18n_attributes(resource_class) - resource_class_ignorable_attributes(resource_class)
  end

  def resource_class_ignorable_attributes(resource_class)
    %w[id created_at updated_at password password_confirmation encrypted_password item_position]
  end

  def resource_class_i18n_attributes(resource_class)
    if resource_class.translates?
      resource_class.translated_attribute_names.map { |a| a.to_s }
    else
      []
    end
  end

  def wrapper(content_or_attributes_with_block, attributes = {}, &block)
    if block_given?
      tag(:div, content_or_attributes_with_block, nil, nil, &block)
    else
      tag(:div, content_or_attributes_with_block, attributes)
    end
  end

  def tag(*args, &block)
    return template.content_tag(*args) unless block_given?

    template.content_tag(*args) do
      block_result = yield
      if block_result.is_a? Array
        safe_join do
          block_result
        end
      else
        block_result
      end
    end
  end

  def safe_join(&block)
    template.safe_join(yield)
  end

  def controller
    template.controller
  end
end
