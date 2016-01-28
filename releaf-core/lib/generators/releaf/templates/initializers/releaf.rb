Releaf.application.configure do
  # Default settings are commented out

  ### setup menu items and therefore available controllers
  config.menu = [
    {
      :controller => 'releaf/content/nodes',
    },
    {
      :name => "permissions",
      :items =>   %w[releaf/permissions/users releaf/permissions/roles],
    },
    {
      :controller => 'releaf/i18n_database/translations',
    },
  ]

  # controllers that must be accessible by user, but are not visible in menu
  # should be added to this list
  config.additional_controllers = ['releaf/permissions/profile']

  config.components = [Releaf::I18nDatabase, Releaf::Permissions, Releaf::Content]

  config.available_locales = ["en"]
  # config.layout_builder_class_name = 'CustomLayoutBuilder'
  # config.devise_for 'releaf/permissions/user'
end
