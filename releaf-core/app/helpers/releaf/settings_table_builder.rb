module Releaf
  class SettingsTableBuilder < Releaf::TableBuilder
    def column_names
      [:var, :value, :updated_at]
    end
  end
end
