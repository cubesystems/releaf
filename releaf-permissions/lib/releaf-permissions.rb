require 'devise'

module Releaf::Permissions
  require 'releaf/permissions/engine'
  require 'releaf/permissions/default_controller_resolver'
  require 'releaf/permissions/settings_manager'
  require 'releaf/permissions/configuration'
  require 'releaf/permissions/layout'
  require 'releaf/permissions/access_control'
  require 'releaf/permissions/controller_support'
  require 'releaf/permissions/profile'
  require 'releaf/permissions/roles'
  require 'releaf/permissions/users'

  def self.components
    [
      Releaf::Permissions::DefaultControllerResolver,
      Releaf::Permissions::SettingsManager,
      Releaf::Permissions::Configuration,
      Releaf::Permissions::Layout,
      Releaf::Permissions::AccessControl,
      Releaf::Permissions::Roles,
      Releaf::Permissions::Users,
      Releaf::Permissions::Profile
    ]
  end
end

