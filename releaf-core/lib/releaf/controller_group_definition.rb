class Releaf::ControllerGroupDefinition
  attr_accessor :name, :controllers

  def initialize(options)
    self.name = options[:name]
    self.controllers = options[:items].map{|option| Releaf::ControllerDefinition.new(option) }
  end

  def localized_name
    I18n.t(name, scope: "admin.controllers")
  end

  def group?
    true
  end
end
