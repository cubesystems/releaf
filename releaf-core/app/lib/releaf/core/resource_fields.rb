class Releaf::Core::ResourceFields
  attr_accessor :resource_class

  def initialize(resource_class)
    self.resource_class = resource_class
  end

  def excluded_attributes
    %w(id created_at updated_at password password_confirmation encrypted_password item_position)
  end

  def fields
    list = base_attributes
    list += localized_attributes if localized_attributes?
    list -= excluded_attributes
    list
  end

  def base_attributes
    resource_class.column_names
  end

  def localized_attributes?
    resource_class.translates?
  end

  def localized_attributes
    resource_class.translated_attribute_names.collect { |a| a.to_s }
  end
end
