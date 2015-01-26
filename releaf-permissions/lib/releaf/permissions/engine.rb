require 'devise'

module Releaf::Permissions
  require 'releaf/permissions/devise_component'
  require 'releaf/permissions/profile_component'
  require 'releaf/permissions/roles_component'
  require 'releaf/permissions/users_component'
  require 'releaf/permissions/builders_autoload'

  class Engine < ::Rails::Engine
  end

  def self.components
    [
      Releaf::Permissions::DeviseComponent,
      Releaf::Permissions::RolesComponent,
      Releaf::Permissions::UsersComponent,
      Releaf::Permissions::ProfileComponent
    ]
  end
end
