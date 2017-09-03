class Releaf::RootController < Releaf::ActionController
  def home
    respond_to do |format|
      format.html do
        redirect_to Releaf.application.config.root.default_controller_resolver.call(current_controller: self)
      end
    end
  end

  def features
    []
  end

  # Store settings for menu collapsing and others
  def store_settings
    if params[:settings].is_a? Hash
      params[:settings].each_pair do|key, value|
        value = false if value == "false"
        value = true if value == "true"
        Releaf.application.config.settings_manager.write(controller: self, key: key, value: value)
      end
      render nothing: true, status: 200
    else
      render nothing: true, status: 422
    end
  end
end
