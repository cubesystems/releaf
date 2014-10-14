module Releaf
  class SettingsFormBuilder < Releaf::FormBuilder
    def render_value
      releaf_text_field(:value)
    end
  end
end
