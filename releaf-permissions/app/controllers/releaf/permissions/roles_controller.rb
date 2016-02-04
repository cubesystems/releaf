class Releaf::Permissions::RolesController < Releaf::ActionController
  def self.resource_class
    Releaf::Permissions::Role
  end
end
