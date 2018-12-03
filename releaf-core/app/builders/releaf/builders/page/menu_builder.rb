module Releaf::Builders::Page
  class MenuBuilder
    include Releaf::InstanceCache
    include Releaf::Builders::Base
    include Releaf::Builders::Template

    def output
      compacter << tag(:nav, menu_level(Releaf.application.config.menu))
    end

    def active?(item)
      instance_cache("active_#{item.class.name}_#{item.name}") do
        if item.group?
          item.controllers.find{|subitem| active?(subitem) }.present?
        else
          item.controller_name == controller.short_name
        end
      end
    end

    def menu_level(items)
      level_content = items.map{|item| menu_item(item) }.compact
      tag(:ul){ level_content } if level_content.present?
    end

    def menu_item(item)
      tag(:li, item_attributes(item)) do
        if item.group?
          menu_item_group(item)
        else
          menu_item_single(item)
        end
      end
    end

    def menu_item_single(item)
      tag(:a, class: "trigger", href: item.path) do
        item_name_content(item)
      end
    end

    def menu_item_group(item)
      tag(:span, class: "trigger") do
        item_name_content(item) << item_collapser(item)
      end << menu_level(item.controllers)
    end

    def collapsed_item?(item)
      item.group? && !active?(item) && layout_settings("releaf.menu.collapsed.#{item.name}") == true
    end

    def item_attributes(item)
      attributes = {
        class: item_classes(item),
        data: {
          name: item.name
        }
      }

      attributes.delete(:class) if attributes[:class].empty?
      attributes
    end

    def item_classes(item)
      list = []
      list << "collapsed" if collapsed_item?(item)
      list << "active" if active?(item)
      list
    end

    def item_name_content(item)
      item_full_name    = item.localized_name
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
end
