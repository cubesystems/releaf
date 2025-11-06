Releaf.application.configure do
  # Default settings are commented out

  ### setup menu items and therefore available controllers
  config.menu = [
    {name: "inventory", items: %w[admin/books admin/authors admin/publishers admin/banners]},
    {name: "permissions", items: %w[releaf/permissions/users releaf/permissions/roles]},
    "releaf/settings",
   ]

  config.additional_controllers = %w[admin/chapters]
  config.components = [Releaf::Core, Releaf::Permissions]
  config.available_locales = ["en", "lv"]
  # conf.layout_builder_class_name = "CustomLayoutBuilder"
  # conf.permissions.devise_for 'releaf/admin'
end
