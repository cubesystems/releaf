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

    def resource_params
      return [] unless %w[update create].include? params[:action]
      return [:name, :default_controller, permissions: []]
    end
  end
end
