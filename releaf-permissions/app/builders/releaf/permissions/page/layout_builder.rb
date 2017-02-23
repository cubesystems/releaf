class Releaf::Permissions::Page::LayoutBuilder < Releaf::Builders::Page::LayoutBuilder
  def header_builder
    Releaf::Permissions::Page::HeaderBuilder
  end

  def menu_builder
    Releaf::Permissions::Page::MenuBuilder
  end

  def body_content_blocks
    if controller.respond_to?(:authorized?) && controller.authorized?
      super
    else
      [yield]
    end
  end
end
