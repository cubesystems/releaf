class Releaf::ControllerDefinition
  attr_accessor :name, :controller_name

  def initialize(options)
    options = {controller: options} if options.is_a? String
    options[:name] ||= options[:controller]
    self.name = options[:name]
    self.controller_name = options[:controller]
  end

  def localized_name
    I18n.t(name, scope: "admin.controllers")
  end

  def path
    Rails.application.routes.url_helpers.url_for(action: :index, controller: controller_name, only_path: true)
  end
end
