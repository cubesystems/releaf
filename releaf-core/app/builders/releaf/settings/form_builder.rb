class Releaf::Settings::FormBuilder < Releaf::Builders::FormBuilder
  def field_names
    [:value]
  end

  def render_value
    send(value_render_method_name, :value, options: { label: { label_text: value_label_text }})
  end

  def value_render_method_name
    "releaf_#{object.input_type}_field"
  end

  def value_label_text
    label_text = object.description
    label_text.present? ? t(label_text, scope: "settings") : translate_attribute(:value)
  end
end
