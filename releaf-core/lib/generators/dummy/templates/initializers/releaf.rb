Releaf.application.configure do
  # Default settings are commented out

  ### setup menu items and therefore available controllers
  config.menu = [
    "admin/nodes",
    {name: "inventory", items: %w[admin/books admin/authors admin/publishers admin/banners]},
    {name: "permissions", items: %w[releaf/permissions/users releaf/permissions/roles]},
    "releaf/settings",
    "releaf/i18n_database/translations"
   ]

  config.additional_controllers = %w[admin/chapters]
  config.components = [Releaf::Core, Releaf::I18nDatabase, Releaf::Permissions, Releaf::Content]
  config.available_locales = ["en", "lv"]
  # conf.layout_builder_class_name = "CustomLayoutBuilder"
  # conf.permissions.devise_for 'releaf/admin'

  config.content.resources = { 'Node' => { controller: 'Admin::NodesController' } }

  # MULTIPLE NODES CASE:
  # config.content.resources = {
    # 'Node' => {
      # controller: 'Releaf::Content::NodesController',
      # routing: {
        # site: "main_site",
        # constraints: { host: /^(www\.)?releaf\.local$/ }
      # }
    # },
    # 'OtherSite::OtherNode' => {
      # controller: 'Admin::OtherSite::OtherNodesController',
      # routing: {
        # site: "other_site",
        # constraints: { host: /^(www\.)?other\.releaf\.local$/ }
      # }
    # }
  # }

  # DEFAULT SINGLE NODE CASE:
  # config.content.resources = { 'Node' => { controller: 'Releaf::Content::NodesController' } }
end
