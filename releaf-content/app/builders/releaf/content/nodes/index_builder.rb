module Releaf::Content::Nodes
  class IndexBuilder < Releaf::Builders::IndexBuilder
    include Releaf::Content::Builders::Tree
    include Releaf::Builders::Toolbox

    def tree_resource_blocks(resource, level, expanded)
      [tree_resource_toolbox(resource)] + super
    end

    def tree_resource_toolbox(resource)
      tag(:div, class: "only-icon toolbox-cell") do
        toolbox(resource[:node], index_path: index_path)
      end
    end

    def pagination?
      false
    end

    def resource_creation_button
      button(t("Create new resource"), "plus", class: %w(primary ajaxbox), href: url_for(controller: controller.controller_name, action: "content_type_dialog"))
    end
  end
end
