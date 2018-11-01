module Releaf::Permissions
  require 'releaf/permissions/devise_component'
  require 'releaf/permissions/profile_component'
  require 'releaf/permissions/roles_component'
  require 'releaf/permissions/users_component.rb'

  class Engine < ::Rails::Engine
    initializer 'precompile', group: :all do |app|
      app.config.assets.precompile += %w(releaf/controllers/releaf/permissions/*)
    end
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
