module Releaf::Permissions
  class UsersController < Releaf::BaseController

    def setup
      super
      @searchable_fields = [:name, :surname, :email]
    end

    def self.resource_class
      Releaf::Permissions::User
    end

    protected

    def prepare_new
      super
      @resource.role = Releaf::Permissions::Role.first
    end

    def permitted_params
      return [] unless %w[create update].include? params[:action]
      %w[name surname role_id email password password_confirmation locale]
    end
  end
end
