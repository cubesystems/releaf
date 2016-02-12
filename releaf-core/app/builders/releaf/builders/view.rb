module Releaf::Builders::View
  include Releaf::Builders::Base
  include Releaf::Builders::Template

  def output
    safe_join do
      list = []
      list << header unless dialog?
      list << section
    end
  end

  def dialog?
    controller.ajax?
  end

  def dialog_name
    self.class.name.split("::").last.gsub(/(Dialog)?Builder$/, "").underscore.dasherize
  end

  def header
    tag(:header) do
      [breadcrumbs, flash_notices, header_extras]
    end
  end

  def section
    tag(:section, section_attributes) do
      section_blocks
    end
  end

  def section_attributes
    attributes = {}
    attributes[:class] = ["dialog", dialog_name] if dialog?
    attributes
  end

  def breadcrumbs
    breadcrumb_items = template_variable("breadcrumbs")
    return unless breadcrumb_items.present?

    tag(:nav) do
      tag(:ul, class: "breadcrumbs") do
        safe_join do
          last_item = breadcrumb_items.last
          breadcrumb_items.each.collect do |item, _index|
            breadcrumb_item(item, item == last_item)
          end
        end
      end
    end
  end

  def breadcrumb_item(item, last)
    content = []
    if item[:url].present?
      content << tag(:a, item[:name], href: item[:url])
    else
      content << item[:name]
    end

    content << icon("chevron-right") unless last

    tag(:li) do
      safe_join{ content }
    end
  end

  def flash_notices
    safe_join do
      flash.collect{|name, item| flash_item(name, item) }
    end
  end

  def flash_item(name, item)
    item_data = {type: name}
    item_data[:id] = item["id"] if item.is_a?(Hash)

    tag(:div, class: "flash", data: item_data) do
      item.is_a?(Hash) ? item["message"] : item
    end
  end

  def header_extras; end

  def section_blocks
    [section_header, section_body, section_footer]
  end

  def section_header
    tag(:header) do
      [tag(:h1, section_header_text), section_header_extras]
    end
  end

  def section_header_text; end
  def section_header_extras; end
  def section_body; end

  def section_footer
    tag(:footer, class: section_footer_class) do
      footer_tools
    end
  end

  def section_footer_class
    :main unless dialog?
  end

  def footer_tools
    tag(:div, class: "tools") do
      footer_blocks
    end
  end

  def footer_blocks
    [footer_primary_block, footer_secondary_block]
  end

  def footer_primary_block
    tag(:div, class: "primary") do
      footer_primary_tools
    end
  end

  def footer_secondary_block
    tag(:div, class: "secondary") do
      footer_secondary_tools
    end
  end

  def footer_primary_tools; end
  def footer_secondary_tools; end
end
