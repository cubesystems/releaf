module Releaf::BuilderCommons
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

  def tag(*args, &block)
    template.content_tag(*args, &block)
  end

  def controller
    template.controller
  end
end
