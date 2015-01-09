module Releaf::Permissions::Users
  class TableBuilder < Releaf::Builders::TableBuilder
    def column_names
      [:name, :surname, :role, :email, :locale]
    end
  end
end
