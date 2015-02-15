module Releaf::Permissions
  class RolesController < Releaf::BaseController
    def self.resource_class
      Releaf::Permissions::Role
    end
  end
end
