module Releaf
  module ButtonHelper
    def releaf_button(text, icon, attributes = {})
      default_attributes = {
        class: "button",
        title: text
      }

      if attributes.key? :url
        tag = :a
      else
        default_attributes[:type] = "button"
        tag = :button
      end

      content_tag(tag, merge_attributes(default_attributes, attributes)) do
        fa_icon(icon) << text
      end
    end
  end
end
