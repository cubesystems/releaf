class Releaf::Permissions::Page::MenuBuilder < Releaf::Builders::Page::MenuBuilder

  def build_items(list)
    super.select{|item| item[:items].present? || controller_permitted?(item[:controller]) }
  end

  def controller_permitted?(controller_name)
    Releaf.application.config.permissions.access_control.new(user: controller.user).controller_permitted?(controller_name)
  end
end
