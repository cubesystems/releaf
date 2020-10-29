class Releaf::SettingsController < Releaf::ActionController

  def self.resource_class
    Releaf::Settings
  end

  def resources
    resource_class.registered
  end

  def searchable_fields
    [:var, :value]
  end

  def resource_params
    {value: Releaf::Settings::NormalizeValue.call(value: super.fetch(:value, nil), input_type: @resource.input_type)}
  end

  def features
    [:index, :edit, :search]
  end
end
