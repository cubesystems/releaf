module Releaf::Permissions::Users
  class FormBuilder < Releaf::Builders::FormBuilder
    def field_names
      %w(name surname locale role_id email password password_confirmation)
    end

    def render_locale
      releaf_item_field(:locale, options: {select_options: locale_options(Releaf.application.config.available_admin_locales)})
    end
  end
end
