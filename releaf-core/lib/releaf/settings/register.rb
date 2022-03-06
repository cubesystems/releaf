class Releaf::Settings::Register
  include Releaf::Service
  attribute :settings, Array

  def call
    settings.each do|item|
      register(normalize(item))
    end
  end

  def normalize(item)
    item[:type] = (item[:type] || :text).to_sym
    dissallowed_keys = item.keys - allowed_keys

    raise Releaf::Error, "Unsupported settings type: #{item[:type]}" unless settings_class.supported_types.include?(item[:type])
    raise Releaf::Error, "Dissallowed settings keys: #{dissallowed_keys}" if dissallowed_keys.present?

    item
  end

  def allowed_keys
    [:key, :default, :type, :description]
  end

  def register(item)
    settings_class.registry.update(item[:key] => item)
    settings_class[item[:key]] = item[:default] if write_default?(item)
  end

  def write_default?(item)
    table_exists? && !settings_class.find_by(var: item[:key]).present?
  end

  def table_exists?
    begin
      settings_class.table_exists?
    rescue ActiveRecord::NoDatabaseError
      false
    end
  end

  def settings_class
    Releaf::Settings
  end
end
