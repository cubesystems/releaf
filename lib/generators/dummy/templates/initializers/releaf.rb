Releaf.setup do |conf|
  # Default settings are commented out

  ### setup menu items and therefore available controllers
   conf.menu = [
    {
      :controller => 'releaf/content',
      :helper => 'releaf_nodes'
    },
    {
      :name => "store",
      :sections => [
        {
          :name => "inventory",
          :items =>   %w[admin/books admin/authors]
       }
      ]
    },
    {
      :name => "permissions",
      :sections => [
        {
          :name => "permissions",
          :items =>   %w[releaf/admins releaf/roles]
       }
      ]
    },
    {
      :controller => 'releaf/translations',
      :helper => 'releaf_translation_groups'
    },
   ]

   conf.available_locales = ["en"]
  # conf.layout = 'releaf/admin'
  # conf.devise_for 'releaf/admin'


  ### Configure YUI
  # You can, for example put YUI in /public and then point this setting to path
  # in public that points to yui-min.js, yui-base-min.js or yui-core-min.js.
  # Or you can point it to different host etc....
  #
  # conf.yui_js_url = 'http://yui.yahooapis.com/3.9.1/build/yui-base/yui-base-min.js'
  #
  # If you need additional configuration, you can set this in yui_config.
  # It will be exported as json and assigned to YUI_config.
  # See http://yuilibrary.com/yui/docs/api/classes/config.html#properties
  # for more info
  #
  # conf.yui_config = {}

end
