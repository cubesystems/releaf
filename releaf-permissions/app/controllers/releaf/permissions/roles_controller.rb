module Releaf::Permissions
  class RolesController < Releaf::BaseController
    def self.resource_class
      Releaf::Permissions::Role
    end

    protected

    def setup
      super
      @features[:edit_ajax_reload] = false
    end
  end
end
