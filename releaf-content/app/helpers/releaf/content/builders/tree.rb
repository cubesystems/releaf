module Releaf::Content::Builders
  module Tree
    def section_body
      tag(:div, class: "body") do
        tree
      end
    end

    def tree
      tag(:div, class: "collection") do
        root_level
      end
    end

    def root_level
      tree_level(collection, 1) unless collection.size < 1
    end

    def tree_level(list, level)
      tag(:ul, class: "block", "data-level" => level) do
        list.collect do |resource|
          tree_resource(resource, level)
        end
      end
    end

    def tree_resource(resource, level)
      expanded = (template.current_admin_user.settings["content.tree.expanded.#{resource.id}"] == true)
      classes = []
      classes << 'collapsed' unless expanded
      classes << 'has-children' unless resource.children.empty?

      tag(:li, class: classes, data: {level: level, id: resource.id}) do
        tree_resource_blocks(resource, level, expanded)
      end
    end

    def tree_resource_blocks(resource, level, expanded)
      [tree_resource_collapser(resource, expanded),
       tree_resource_name(resource), tree_resource_children(resource, level)]
    end

    def tree_resource_collapser(resource, expanded)
      return if resource.children.empty?
      tag(:div, class: "collapser-cell") do
        button(nil, (expanded ? 'chevron-down' : 'chevron-right'), class: %w(secondary collapser), title: t(expanded ? "collapse" : "expand"))
      end
    end

    def tree_resource_children(resource, level)
      return if resource.children.empty?
      tree_level(resource.children, level + 1)
    end

    def tree_resource_name(resource)
      classes = ["node-cell"]
      classes << "active" if resource.active?

      tag(:div, class: classes) do
        tree_resource_name_button(resource)
      end
    end

    def tree_resource_name_button(resource)
      title = resource.content_id.present? ? "#{resource.content_type} ##{resource.content_id}" : resource.content_type
      tag(:a, href: url_for(action: "edit", id: resource.id), title: title) do
        tag(:span, resource.name)
      end
    end
  end
end
