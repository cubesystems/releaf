module Releaf::Content::Builders
  module ActionDialog
    include Releaf::Content::Builders::Dialog

    def form_attributes
      {
        method: :post,
        data: {
          "remote" => true,
          "remote-validation" => true,
          "type" => :json
        }
      }
    end

    def root_level
      tag(:ul, class: "block", "data-level" => 0) do
        tag(:li, class: "root") do
          [tree_root_resource, super]
        end
      end
    end

    def tree_root_resource
      field_id = "new_parent_id_0"
      tag(:div, class: "node-cell") do
        [radio_button_tag(:new_parent_id, '', false, id: 'new_parent_id_0'),
           tag(:label, t("Root node"), for: field_id)]
      end
    end

    def tree_resource_name_button(resource)
      field_id = "new_parent_id_#{resource.id}"

      [radio_button_tag(:new_parent_id, resource.id, false, id: field_id),
         tag(:label, tag(:span, resource.name), for: field_id)]
    end

    def section_blocks
      form_tag(url_for(action: action, id: resource.id), form_attributes) do
        safe_join do
          super
        end
      end
    end

    def section_header_text
      message = "#{action.capitalize} node '%{node_name}' to"
      t(message, default: message, node_name: resource.name )
    end

    def footer_primary_tools
      super << confirm_button
    end

    def confirm_button
      button(t(action), "check", class: "primary", type: "submit", data: { type: 'ok', disable: true })
    end
  end
end
