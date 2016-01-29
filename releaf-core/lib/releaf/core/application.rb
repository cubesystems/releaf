module Releaf::Core
  class Application
    attr_accessor :config

    def configure(&block)
      self.config = Releaf::Core::Configuration.new
      config.initialize_defaults
      instance_eval(&block)
      config.initialize_locales
      config.initialize_controllers
    end

    def render_layout(template, &block)
      builder_class = config.layout_builder_class_name.constantize
      builder_class.new(template).output{ yield }.html_safe
    end
  end
end

