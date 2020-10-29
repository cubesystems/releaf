module Releaf::Content
  class ContentTypeDialogBuilder
    include Releaf::Content::Builders::Dialog
    attr_accessor :content_types

    def initialize(template)
      super
      self.content_types = template_variable("content_types")
    end

    def content_types_slices
      min_items_per_column = 4
      items_per_column = (content_types.length / 2.0).ceil

      if items_per_column < min_items_per_column
        items_per_column = min_items_per_column
      end

      slices = []
      slices.push content_types[0...items_per_column]
      if items_per_column < content_types.length
        slices.push content_types[items_per_column..-1]
      end

      slices
    end

    def section_attributes
      attributes = super
      attributes['data-columns'] = content_types_slices.length
      attributes
    end

    def section_body
      tag(:div, class: "body") do
        [section_body_description, content_types_list]
      end
    end

    def content_types_list
      tag(:div, class: "content-types") do
        content_types_slices.collect do |slice|
          content_type_slice(slice)
        end
      end
    end

    def content_type_slice(slice)
      tag(:ul) do
        slice.collect do|content_type|
          content_type_item(content_type)
        end
      end
    end

    def content_type_item(content_type)
      url = url_for(controller: controller.controller_path, action: "new", parent_id: params[:parent_id], content_type: content_type.name)
      tag(:li) do
        link_to(I18n.t(content_type.name.underscore, scope: 'admin.content_types'), url)
      end
    end


    def section_body_description
      tag(:div, class: "description") do
        t("Select content type of new node")
      end
    end

    def section_header_text
      t("Create new resource")
    end
  end
end
