class Releaf::Core::SettingsController < ::Releaf::BaseController

  def self.resource_class
    ::Releaf::Settings
  end

  def resources
    super.where(thing_type: nil)
  end

  def fields_to_display
    return %w[var value updated_at] if params[:action] == 'index'
    return %w[value]
  end

  def update
    @resource = resource_class.find(params[:id]) unless resource_given?
    maintain_value_type
    super
  end

  def maintain_value_type
    if @resource.value.class == Time
      params[:resource][:value] = Time.parse(params[:resource][:value])
    end
  end

  protected

  def setup
    super
    @searchable_fields = [:var]
    @features[:create]  = false
    @features[:destroy] = false
  end
end
