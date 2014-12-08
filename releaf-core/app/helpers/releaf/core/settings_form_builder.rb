module Releaf::Core
  class SettingsFormBuilder < Releaf::Builders::FormBuilder
    def field_names
      [:value]
    end

    def render_value
      releaf_text_field(:value)
    end
  end
end
