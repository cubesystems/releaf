class Releaf::ControllerDefinition
  attr_accessor :name, :controller_name, :helper

  def self.for(controller_name)
    Releaf.application.config.controllers[controller_name]
  end

  def initialize(options)
    options = {controller: options} if options.is_a? String
    options[:name] ||= options[:controller]
    self.name = options[:name]
    self.controller_name = options[:controller]
    self.helper = "#{options[:helper]}_path" if options[:helper]
  end

  def group?
    false
  end

  def localized_name
    I18n.t(name, scope: "admin.controllers")
  end

  def path
    if helper
      Rails.application.routes.url_helpers.send(helper)
    else
      Rails.application.routes.url_helpers.url_for(action: :index, controller: controller_name, only_path: true)
    end
  end
end
