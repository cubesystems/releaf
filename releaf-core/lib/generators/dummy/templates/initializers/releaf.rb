Releaf.application.configure do
  # Default settings are commented out

  ### setup menu items and therefore available controllers
  config.menu = [
    {
      :controller => 'releaf/content/nodes',
      :icon => 'sitemap',
    },
    {
      :name => "inventory",
      :items =>   %w[admin/books admin/authors admin/publishers],
      :icon => 'briefcase',
    },
    {
      :name => "permissions",
      :items =>   %w[releaf/permissions/users releaf/permissions/roles],
      :icon => 'user',
    },
    {
      :controller => "releaf/core/settings",
      :icon => 'cog',
    },
    {
      :controller => 'releaf/i18n_database/translations',
      :icon => 'group',
    },
   ]

  config.additional_controllers = %w[admin/chapters releaf/permissions/profile]
  config.components = [Releaf::I18nDatabase, Releaf::Permissions, Releaf::Content, Releaf::Core::SettingsUI]
  config.available_locales = ["en", "lv"]
  # conf.layout_builder_class_name = "CustomLayoutBuilder"
  # conf.devise_for 'releaf/admin'
end
