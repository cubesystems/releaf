class Releaf::Settings < RailsSettings::Base

  scope :registered, -> { where(var: registered_keys).order(:var) }

  cattr_accessor :registry
  @@registry = {}.with_indifferent_access

  def releaf_title
    var
  end

  def input_type
    metadata[:type] || :text
  end

  def description
    metadata[:description]
  end

  def metadata
    self.class.registry.fetch(var, {})
  end

  def self.register_scoped
    where(var: registered_keys)
  end

  def self.registered_keys
    @@registry.keys
  end

  def self.register(*args)
    Releaf::Settings::Register.call(settings: args)
  end

  def self.supported_types
    [:boolean, :date, :time, :datetime, :integer, :float, :decimal, :email, :text, :textarea, :richtext]
  end
end
