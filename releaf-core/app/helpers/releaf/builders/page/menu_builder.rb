class Releaf::Builders::Page::MenuBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::Template

  class Menu
    mattr_accessor :permissions_manager

    def self.build(list, permissions_manager)
      self.permissions_manager = permissions_manager
      build_list(list)
    end

    def self.build_list(list)
      list.collect{|item| build_item(item) }.compact
    end

    def self.build_item(source_item)
      item = source_item.dup
      item[:items] = build_list(item.fetch(:items, []))
      item.delete(:items) if item[:items].empty?

      if item[:items]
        item[:active]  = item[:items].find{|i| i[:active] == true }.present?
        item[:url_helper] = item[:items].first[:url_helper] if item[:items].present?
        item
      elsif permissions_manager.authorize_controller!(item[:controller])
        item[:active] = active_controller?(item[:controller])
        item
      else
        nil
      end
    end

    def self.active_controller?(controller_name)
      permissions_manager.current_controller_name == controller_name
    end
  end

  def output
    menu_items = Menu.build(Releaf.menu, permissions_manager)
    compacter << tag(:nav, menu_level(menu_items))
  end

  def menu_level(items)
    tag(:ul, class: "block") do
      items.collect{|item| menu_item(item) }
    end
  end

  def menu_item(item)
    tag(:li, item_attributes(item)) do
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

  def collapsed_item?(item)
    item[:items] && !item[:active] && layout_settings("releaf.menu.collapsed.#{item[:name]}") == true
  end

  def item_attributes(item)
    attributes = {
      class: [],
      data: {
        name: item[:name]
      }
    }

    attributes[:class] << "collapsed" if collapsed_item?(item)
    attributes[:class] << "active" if item[:active]
    attributes.delete(:class) if attributes[:class].empty?

    attributes
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

  def compacter
    tag(:div, class: "compacter") do
      tag(:button, type: "button") do
        icon("angle-double-" + (layout_settings('releaf.side.compact') ? "right" : "left"))
      end
    end
  end
end
