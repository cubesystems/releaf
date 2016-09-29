class Releaf::Settings::TableBuilder < Releaf::Builders::TableBuilder
  def column_names
    [:var, :value, :updated_at]
  end

  def value_content(resource)
    send(type_format_method(resource.input_type), resource, :value)
  end
end
