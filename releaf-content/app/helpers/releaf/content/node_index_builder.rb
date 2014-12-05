module Releaf::Content
  class NodeIndexBuilder < Releaf::Builders::IndexBuilder
    include Releaf::Content::Builders::Tree

    def tree_resource_blocks(resource, level, expanded)
      [tree_resource_toolbox(resource)] + super
    end

    def tree_resource_toolbox(resource)
      tag(:div, class: "toolbox-cell") do
        template.toolbox(resource, index_url: index_url)
      end
    end

    def pagination?
      false
    end

    def resource_creation_button
      button(t('Create new resource', scope: 'admin.global'), "plus", class: %w(primary ajaxbox), href: url_for(controller: controller.controller_name, action: "new"))
    end
  end
end
