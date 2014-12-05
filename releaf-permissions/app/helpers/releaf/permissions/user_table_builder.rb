module Releaf::Permissions
  class UserTableBuilder < Releaf::Builders::TableBuilder
    def column_names
      [:name, :surname, :role, :email, :locale]
    end
  end
end
