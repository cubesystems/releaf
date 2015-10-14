module Releaf::Core
  class Application
    attr_accessor :config

    def configure(&block)
      self.config = Releaf::Core::Configuration.new
      instance_eval(&block)
      config.configure
    end

    def render_layout(template, &block)
      builder_class = config.layout_builder_class_name.constantize
      builder_class.new(template).output{ yield }.html_safe
    end
  end
end

