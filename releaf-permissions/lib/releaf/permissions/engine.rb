require 'devise'

module Releaf::Permissions
  require 'releaf/permissions/devise'
  require 'releaf/permissions/profile'
  require 'releaf/permissions/roles'
  require 'releaf/permissions/users'
  require 'releaf/permissions/builders_autoload'

  class Engine < ::Rails::Engine
    initializer 'precompile', group: :all do |app|
      app.config.assets.precompile += %w(releaf/controllers/releaf/permissions/*)
    end
  end

  def self.components
    [
      Releaf::Permissions::Devise,
      Releaf::Permissions::Roles,
      Releaf::Permissions::Users,
      Releaf::Permissions::Profile
    ]
  end
end
