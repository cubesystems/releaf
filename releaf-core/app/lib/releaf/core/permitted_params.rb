class Releaf::Core::PermittedParams
  attr_accessor :resource_class

  def initialize(resource_class)
    self.resource_class = resource_class
  end

  def excluded_attributes
    %w{id created_at updated_at}
  end

  def file_attributes
    resource_class.dragonfly_attachment_classes.collect{|c| "#{c.attribute}_uid" }
  end

  def file_attribute?(column)
    file_attributes.include? column
  end

  def file_attribute_params(column)
    file_field = column.gsub(/_uid$/, "")
    [file_field, "retained_#{file_field}", "remove_#{file_field}"]
  end

  def params
    list = base_params
    list += localized_attributes if localized_attributes?
    list
  end

  def base_params
    (resource_class.column_names - excluded_attributes).inject([]) do|list, attribute|
      if file_attribute?(attribute)
        list += file_attribute_params(attribute)
      else
        list << attribute
      end
    end
  end

  def localized_attributes?
    resource_class.translates?
  end

  def localized_attributes
    resource_class.translated_attribute_names.inject([]) do |list, column|
      list += localized_attribute_params(column)
    end
  end

  def localized_attribute_params(column)
    resource_class.globalize_locales.collect do|locale|
      "#{column}_#{locale}"
    end
  end
end
