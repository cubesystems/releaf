class Releaf::Core::SettingsController < ::Releaf::BaseController

  def self.resource_class
    ::Releaf::Settings
  end

  def resources
    super.where(thing_type: nil, var: resource_class.registered_keys)
  end

  def maintain_value_type
    case resource_class.registry[@resource.var][:type]
    when :boolean
      params[:resource][:value] = params[:resource][:value] == '1'
    when :date
      params[:resource][:value] = Date.parse(params[:resource][:value])
    when :time
      params[:resource][:value] = Time.parse(params[:resource][:value])
    when :datetime
      params[:resource][:value] = DateTime.parse(params[:resource][:value])
    when :integer
      params[:resource][:value] = params[:resource][:value].to_i
    when :float
      params[:resource][:value] = params[:resource][:value].to_s.sub(",", ".").to_f
    when :decimal
      params[:resource][:value] = params[:resource][:value].to_s.sub(",", ".").to_d
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
    }
  end
end
