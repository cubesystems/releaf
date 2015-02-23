module Releaf::Permissions::Profile
  class FormBuilder < Releaf::Permissions::Users::FormBuilder
    def field_names
      %w(name surname locale email password password_confirmation)
    end
  end
end
