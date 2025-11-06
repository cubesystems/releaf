Releaf.application.configure do
  # Default settings are commented out

  ### setup menu items and therefore available controllers
  config.menu = [
    {name: "permissions", items: %w[releaf/permissions/users releaf/permissions/roles]},
  ]

  # controllers that must be accessible by user, but are not visible in menu
  # should be added to this list
  # config.additional_controllers = %w[admin/chapters]
  config.components = [Releaf::Core, Releaf::Permissions]

  config.available_locales = ["en"]
  # config.layout_builder_class_name = 'CustomLayoutBuilder'
  # config.permissions.devise_for 'releaf/admin'
end
