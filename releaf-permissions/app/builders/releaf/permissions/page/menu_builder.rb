class Releaf::Permissions::Page::MenuBuilder < Releaf::Builders::Page::MenuBuilder

  def menu_item(item)
    super if menu_item_permitted?(item)
  end

  def menu_item_permitted?(item)
    if item.group?
      item.controllers.find{|subitem| controller_permitted?(subitem.controller_name) }.present?
    else
      controller_permitted?(item.controller_name)
    end
  end

  def controller_permitted?(controller_name)
    access_control.controller_permitted?(controller_name)
  end

  def access_control
    @access_control ||= Releaf.application.config.permissions.access_control.new(user: controller.user)
  end
end
