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
    settings = params.permit(settings: [:key, :value]).to_h.fetch(:settings, nil)
    if settings
      settings.each do|item|
        next if item[:key].nil? || item[:value].nil?
        item[:value] = true if item[:value] == "true"
        item[:value] = false if item[:value] == "false"
        Releaf.application.config.settings_manager.write(controller: self, key: item[:key], value: item[:value])
      end
      head :ok
    else
      head :unprocessable_entity
    end
  end
end
