class Releaf::ResourceParams < Releaf::ResourceBase

  def file_attributes
    resource_class.dragonfly_attachment_classes.collect{|c| "#{c.attribute}_uid" }
  end

  def file_attribute?(column)
    file_attributes.include? column
  end

  def file_attribute_params(column)
    file_field = column.sub(/_uid$/, "")
    [file_field, "retained_#{file_field}", "remove_#{file_field}"]
  end

  def base_attributes
    super.inject([]) do|list, attribute|
      if file_attribute?(attribute)
        list + file_attribute_params(attribute)
      else
        list << attribute
      end
    end
  end

  def localized_attributes
    super.inject([]) do |list, column|
      list + localized_attribute_params(column)
    end
  end

  def localized_attribute_params(column)
    resource_class.globalize_locales.collect do|locale|
      "#{column}_#{locale}"
    end
  end

  def associations_attributes
    associations.collect do |association|
      {"#{association.name}_attributes" => association_attributes(association)}
    end
  end

  def association_attributes(association)
    super + ["id", "_destroy"]
  end
end
