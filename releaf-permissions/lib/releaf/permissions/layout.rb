module Releaf::Permissions::Layout
  def self.configure_component
    Releaf.application.config.layout_builder_class_name = 'Releaf::Permissions::Page::LayoutBuilder'
  end
end
