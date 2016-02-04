class Releaf::Permissions::UsersController < Releaf::ActionController
  def self.resource_class
    Releaf::Permissions::User
  end

  protected

  def prepare_new
    super
    @resource.role = Releaf::Permissions::Role.first
  end

  def permitted_params
    %w[name surname role_id email password password_confirmation locale]
  end
end
