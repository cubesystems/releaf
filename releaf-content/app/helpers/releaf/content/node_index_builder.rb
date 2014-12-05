module Releaf::Content
  class NodeIndexBuilder < Releaf::Builders::IndexBuilder
    def section_body
      tag(:div, class: "body") do
        tree_level(collection, 1) unless collection.size < 1
      end
    end

    def tree_level(list, level)
      tag(:ul, class: "block", "data-level" => level) do
        list.collect do |resource|
          resource_row(resource, level)
        end
      end
    end

    def resource_row(resource, level)
      expanded = (template.current_admin_user.settings["content.tree.expanded.#{resource.id}"] == true)
      classes = ["row"]
      classes << 'collapsed' unless expanded
      classes << 'has-children' unless resource.children.empty?

      tag(:li, class: classes, data: {level: level, id: resource.id}) do
        [resource_toolbox(resource), resource_collapser(resource, expanded),
         resource_name(resource), resource_children(resource, level)]
      end
    end

    def resource_collapser(resource, expanded)
      return if resource.children.empty?
      tag(:div, class: "collapser-cell") do
        button(nil, (expanded ? 'chevron-down' : 'chevron-right'), class: %w(secondary collapser), title: t(expanded ? "collapse" : "expand"))
      end
    end

    def resource_toolbox(resource)
      tag(:div, class: "toolbox-cell") do
        template.toolbox(resource, index_url: index_url)
      end
    end

    def resource_children(resource, level)
      return if resource.children.empty?
      tree_level(resource.children, level + 1)
    end

    def resource_name(resource)
      resource_title = resource.content_id.present? ? "#{resource.content_type} ##{resource.content_id}" : resource.content_type
      classes = ["node-cell"]
      classes << "active" if resource.active?

      tag(:div, class: classes) do
        tag(:a, href: url_for(action: "edit", id: resource.id), title: resource_title) do
          tag(:span, resource.name)
        end
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
