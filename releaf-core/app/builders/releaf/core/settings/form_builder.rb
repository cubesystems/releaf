module Releaf::Core::Settings
  class FormBuilder < Releaf::Builders::FormBuilder
    def field_names
      [:value]
    end

    def render_value
      method_name = "releaf_#{settings_field_type}_field"
      send(method_name, :value, options: { label: { label_text: settings_field_label_text }})
    end

    def settings_field_label_text
      label_text = Releaf::Settings.registry[object.var][:description]
      label_text.present? ? t(label_text, scope: "settings") : "Value"
    end

    def settings_field_type
      Releaf::Settings.registry[object.var].fetch(:type, :text)
    end
  end
end
