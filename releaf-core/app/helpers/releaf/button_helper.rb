module Releaf
  module ButtonHelper

    def releaf_button(text, icon, attributes = {})
      attributes = releaf_button_attributes( text, icon, attributes )
      tag = attributes.key?(:href) ? :a : :button
      content_tag(tag, attributes) do
        releaf_button_content( text, icon, attributes )
      end
    end


    def releaf_button_attributes( text, icon, attributes = {} )
      default_attributes = {
        class: ["button"],
        title: text
      }

      unless attributes.key? :href
        default_attributes[:type] = :button
        default_attributes[:autocomplete] = "off"
      end

      if icon.present?
        icon_class = (text.present?) ? "with-icon" : "only-icon"
        default_attributes[:class] << icon_class
      end

      merge_attributes(default_attributes, attributes)
    end


    def releaf_button_content( text, icon, attributes = {} )
      if text.blank? && icon.present?
        raise ArgumentError, "Title is required for icon-only buttons" if attributes[:title].blank?
      end

      html = "".html_safe
      html << fa_icon(icon) if icon.present?
      html << text if text.present?

      if html.length < 1
        raise ArgumentError, "Either text or icon is required for buttons"
      end

      html
    end

  end
end
