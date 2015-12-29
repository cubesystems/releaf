class Releaf::Builders::Page::MenuBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::Template

  class Menu
    mattr_accessor :access_control

    def self.build(list, access_control)
      self.access_control = access_control
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
      elsif access_control.controller_permitted?(item[:controller])
        item[:active] = active_controller?(item[:controller])
        item
      else
        nil
      end
    end

    def self.active_controller?(controller_name)
      access_control.current_controller_name == controller_name
    end
  end

  def output
    menu_items = Menu.build(Releaf.application.config.menu, access_control)
    compacter << tag(:nav, menu_level(menu_items))
  end

  def menu_level(items)
    tag(:ul) do
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
    item_full_name    = t(item[:name], scope: "admin.controllers")
    item_abbreviation = item_name_abbreviation( item_full_name )

    tag(:abbr, item_abbreviation, title: item_full_name) + tag(:span, item_full_name, class: "name")
  end

  def item_name_abbreviation( item_full_name )
    return "" if item_full_name.blank?
    # use the first two letters after the last slash that is not preceded by a space
    # to avoid identical abbreviations for namespaced items in case of missing translations
    # but still use the first word in cases of user-entered slashes, e.g. "Inputs / Outputs"
    item_full_name.split(/(?<!\s)\//).last.to_s[0..1].mb_chars.capitalize
  end

  def item_collapser(item)
    tag(:span, class: "collapser") do
      tag(:button, type: "button") do
        item_collapser_icon(item)
      end
    end
  end

  def compact_side?
    layout_settings('releaf.side.compact')
  end

  def item_collapser_icon(item)
    if compact_side?
      icon("chevron-right")
    else
      icon(collapsed_item?(item) ? "chevron-down" : "chevron-up")
    end
  end

  def compacter
    tag(:div, class: "compacter") do
      if compact_side?
        icon_name = "angle-double-right"
        title_attribute = 'title-expand'
      else
        icon_name = "angle-double-left"
        title_attribute = 'title-collapse'
      end
      button(nil, icon_name, title: compacter_data[title_attribute], data: compacter_data )
    end
  end

  def compacter_data
    {
      'title-expand'   => t("Expand", scope: :admin),
      'title-collapse' => t("Collapse", scope: :admin)
    }
  end


end
