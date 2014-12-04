module Releaf::ViewBuilder
  include Releaf::Builder
  attr_accessor :template

  def initialize(template)
    self.template = template
  end

  def header
    tag(:header) do
      [breadcrumbs, flash_notices, header_extras]
    end
  end

  def breadcrumbs
    breadcrumb_items = template.instance_variable_get("@breadcrumbs")
    return nil unless breadcrumb_items.present?

    tag(:nav) do
      tag(:ul, class: "block breadcrumbs") do
        safe_join do
          last_item = breadcrumb_items.last
          breadcrumb_items.each.collect do |item, index|
            breadcrumb_item(item, item == last_item)
          end
        end
      end
    end
  end

  def breadcrumb_item(item, last)
    tag(:li) do
      if item[:url].present?
        tag(:a, href: item[:url]) do
          item[:name]
        end
      else
        item[:name]
      end << ( template.fa_icon("small chevron-right") unless last)
    end
  end

  def flash_notices
    safe_join do
      template.flash.collect do |name, item|
        flash(name, item)
      end
    end
  end

  def flash(name, item)
    tag(:div, class: "flash", 'data-type' => name, :'data-id' => (item.is_a? (Hash)) && (item.has_key? "id") ? item["id"] : nil) do
      item.is_a?(Hash) ? item["message"] : item
    end
  end

  def header_extras
  end

  #
  # Aliases
  #

  def url_for(*args)
    template.url_for(*args)
  end

  def controller_name
    template.controller_name
  end

  def releaf_button(*args)
    template.releaf_button(*args)
  end
end
