module Releaf::Permissions::Users
  class TableBuilder < Releaf::Builders::TableBuilder
    def column_names
      [:name, :surname, :role, :email, :locale]
    end

    def locale_content(resource)
      translate_locale(resource.locale)
    end
  end
end
