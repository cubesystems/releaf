module Releaf::Permissions
  require 'releaf/permissions/profile_component'
  require 'releaf/permissions/roles_component'
  require 'releaf/permissions/users_component.rb'

  class Engine < ::Rails::Engine
  end

  def self.components
    [
      Releaf::Permissions::RolesComponent,
      Releaf::Permissions::UsersComponent,
      Releaf::Permissions::ProfileComponent
    ]
  end
end
