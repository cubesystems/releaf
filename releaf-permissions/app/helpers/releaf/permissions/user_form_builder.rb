module Releaf::Permissions
  class UserFormBuilder < Releaf::FormBuilder
    def render_locale
      releaf_item_field(:locale, options: {select_options: Releaf.available_admin_locales})
    end
  end
end
