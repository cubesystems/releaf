Releaf.setup do |conf|
  # Default settings are commented out

  ### setup menu items and therefore available controllers
   conf.menu = [
    {
      :controller => 'releaf/content',
      :helper => 'releaf_nodes',
      :icon => 'file-text-o',
    },
    {
      :name => "inventory",
      :items =>   %w[admin/books admin/authors],
      :icon => 'briefcase',
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

  conf.additional_controllers = %w[admin/chapters]

  conf.available_locales = ["en", "lv"]
  # conf.layout = 'releaf/admin'
  # conf.devise_for 'releaf/admin'
end
