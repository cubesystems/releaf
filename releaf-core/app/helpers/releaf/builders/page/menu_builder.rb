class Releaf::Builders::Page::MenuBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::Template

  delegate :permissions_manager, to: :controller

  def output
    compacter << tag(:nav, menu_level(menu_items(Releaf.menu)))
  end

  def compacter
    tag(:div, class: "compacter") do
      tag(:button, type: "button") do
        icon("angle-double-" + (layout_settings('releaf.side.compact') ? "right" : "left"))
      end
    end
  end

  def menu_level(items)
    tag(:ul, class: "block") do
      items.collect do|item|
        build_menu_item(item)
      end
    end
  end

  def collapsed_item?(item)
    permissions_manager.user.settings["releaf.menu.collapsed.#{item[:name]}"] == true && !item[:active]
  end

  def menu_items(items)
    items.collect{|item| get_releaf_menu_item(item)}.compact
  end

  def active_controller?(controller_name)
    permissions_manager.current_controller_name == controller_name
  end

  def get_releaf_menu_item(source_item)
    item = {
      icon: source_item[:icon] || "caret-left",
      name: source_item[:name],
      url_helper: source_item[:url_helper],
      attributes: {
        class: [],
        data: {
          name: source_item[:name]
        }
      }
    }

    if source_item[:items]
      item[:items] = menu_items(source_item[:items])
      item[:active]  = item[:items].find{|i| i[:active] == true }.present?
      item[:attributes][:class] << "collapsed" if collapsed_item?(item)
      valid = item[:items].present?
      item[:url_helper] = item[:items].first[:url_helper] if valid
    else
      valid = permissions_manager.authorize_controller!(source_item[:controller])
      item[:active] = active_controller?(source_item[:controller])
    end

    if valid
      item[:attributes][:class] << "active" if item[:active]
      item[:attributes].delete(:class) if item[:attributes][:class].empty?
      item
    else
      nil
    end
  end

  def item_name_content(item)
    icon(item[:icon]) << tag(:span, t(item[:name], scope: "admin.menu_items"), class: "name")
  end

  def item_collapser(item)
    tag(:span, class: "collapser") do
      tag(:button, type: "button") do
        icon(collapsed_item?(item) ? "chevron-down" : "chevron-up")
      end
    end
  end

  def build_menu_item(item)
    tag(:li, item[:attributes]) do
      if item[:items]
        tag(:span, class: "trigger") do
          item_name_content(item) << item_collapser(item)
        end << menu_level(item[:items])
      else
        tag(:a, class: "trigger", href: url_for(item[:url_helper])) do
          item_name_content(item)
        end
      end
    end
  end
end
