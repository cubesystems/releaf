module Releaf::Core
  class SettingsTableBuilder < Releaf::Builders::TableBuilder
    def column_names
      [:var, :value, :updated_at]
    end

    def value_content(resource)
      resource.value.to_s
    end
  end
end
