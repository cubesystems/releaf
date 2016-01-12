Releaf.application.configure do
  # Default settings are commented out

  ### setup menu items and therefore available controllers
  config.menu = [
    {
      :controller => 'admin/nodes'
    },
    {
      :name => "inventory",
      :items =>   %w[admin/books admin/authors admin/publishers],
    },
    {
      :name => "permissions",
      :items =>   %w[releaf/permissions/users releaf/permissions/roles],
    },
    {
      :controller => "releaf/core/settings",
    },
    {
      :controller => 'releaf/i18n_database/translations',
    },
   ]

  config.additional_controllers = %w[admin/chapters releaf/permissions/profile]
  config.components = [Releaf::I18nDatabase, Releaf::Permissions, Releaf::Content, Releaf::Core::SettingsUIComponent]
  config.available_locales = ["en", "lv"]
  # config.layout_builder_class_name = "CustomLayoutBuilder"
  # config.devise_for 'releaf/admin'

  config.content_resources = { 'Node' => { controller: 'Admin::NodesController' } }

  # MULTIPLE NODES CASE:
  # config.content_resources = {
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
  # config.content_resources = { 'Node' => { controller: 'Releaf::Content::NodesController' } }

end
