Releaf.setup do |conf|
  # Default settings are commented out

  ### setup menu items and therefore available controllers
  conf.menu = [
    {
      :controller => 'releaf/content',
      :helper => 'releaf_nodes',
      :icon => 'file-text-alt',
    },
    {
      :name => "permissions",
      :items =>   %w[releaf/admins releaf/roles],
      :icon => 'user',
    },
    {
      :controller => 'releaf/translations',
      :helper => 'releaf_translation_groups',
      :icon => 'group',
    },
  ]

  # controllers that must be accessible by admin, but are not visible in menu
  # should be added to this list
  conf.additional_controllers = []

  conf.available_locales = ["en"]
  # conf.layout = 'releaf/admin'
  # conf.devise_for 'releaf/admin'
end
