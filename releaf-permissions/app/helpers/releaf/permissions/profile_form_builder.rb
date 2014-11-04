module Releaf::Permissions
  class ProfileFormBuilder < Releaf::Permissions::UserFormBuilder
    def field_names
      %w(name surname locale email password password_confirmation)
    end
  end
end
