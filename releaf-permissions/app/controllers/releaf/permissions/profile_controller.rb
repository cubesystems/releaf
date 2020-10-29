class Releaf::Permissions::ProfileController < Releaf::ActionController
  def load_resource
    # assign current user
    @resource = user.becomes(resource_class)
  end

  def success_path
    url_for(action: :edit)
  end

  def update
    load_resource
    old_password = @resource.password
    super

    # reload resource as password has been changed
    if @resource.password != old_password
      bypass_sign_in(user)
    end
  end

  def self.resource_class
    Releaf.application.config.permissions.devise_model_class
  end

  def controller_breadcrumb; end

  def features
    [:edit]
  end

  def permitted_params
    %w[name surname email password password_confirmation locale]
  end
end
