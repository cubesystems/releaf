class Releaf::Core::SettingsController < ::Releaf::BaseController

  def self.resource_class
    ::Releaf::Settings
  end

  def resources
    super.where(thing_type: nil, var: resource_class.registered_keys)
  end

  def maintain_value_type
    if @resource.value.class == Time
      params[:resource][:value] = Time.parse(params[:resource][:value])
    end
  end

  protected

  def prepare_update
    @resource = resource_class.find(params[:id]) unless resource_given?
    maintain_value_type
  end

  def setup
    super
    @searchable_fields = [:var]
    @features = {
      edit: true,
      index: true,
      edit_ajax_reload: true
    }
  end
end
