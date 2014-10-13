module Releaf
  module ButtonHelper
    def releaf_button(text, icon, attributes = {})
      default_attributes = {
        class: ["button"],
        title: text
      }

      if attributes.key? :href
        tag = :a
      else
        default_attributes[:type] = "button"
        tag = :button
      end

      if text.blank?
        default_attributes[:class] << "only-icon"
        # title is required for only-icon buttons / links
        raise ArgumentError, "Title missing for icon-only button/link" if attributes[:title].blank?
      else
        default_attributes[:class] << "with-icon"
      end

      content_tag(tag, merge_attributes(default_attributes, attributes)) do
        fa_icon(icon) << text
      end
    end
  end
end
