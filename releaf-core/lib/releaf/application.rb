module Releaf
  class Application
    attr_accessor :config

    def configure(&block)
      self.config = Releaf::Configuration.new
      instance_eval(&block)
      config.initialize_locales
      config.initialize_components
    end

    def render_layout(template)
      builder_class = config.layout_builder_class_name.constantize
      builder_class.new(template).output{ yield }.html_safe
    end
  end
end

