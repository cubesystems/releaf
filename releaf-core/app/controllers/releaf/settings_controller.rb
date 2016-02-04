class Releaf::SettingsController < Releaf::ActionController

  def self.resource_class
    ::Releaf::Settings
  end

  def resources
    super.where(thing_type: nil, var: resource_class.registered_keys)
  end

  def normalize_value(value)
    case resource_class.registry[@resource.var][:type]
    when :boolean
      value == '1'
    when :date
      Date.parse(value)
    when :time
      Time.parse(value)
    when :datetime
      DateTime.parse(value)
    when :integer
      value.to_i
    when :float
      value.to_s.sub(",", ".").to_f
    when :decimal
      value.to_s.sub(",", ".").to_d
    else
      value
    end
  end

  def searchable_fields
    [:var]
  end

  protected

  def prepare_update
    @resource = resource_class.find(params[:id]) unless resource_given?
    params[:resource][:value] = normalize_value(params[:resource][:value])
  end

  def setup
    super
    self.features = {
      edit: true,
      index: true,
    }
  end
end
