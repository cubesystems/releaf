module Releaf::Content::Nodes
  class ToolboxBuilder < Releaf::Builders::ToolboxBuilder
    def items
      list = []

      unless resource.new_record?
        list << add_child_button
        list << copy_button
        list << move_button
      end

      list + super
    end

    def add_child_button
      button(t('Add child'), nil, class: "ajaxbox", href: url_for(action: "content_type_dialog", parent_id: resource.id))
    end

    def copy_button
      button(t('Copy'), nil, class: "ajaxbox", href: url_for(action: "copy_dialog", id: resource.id))
    end

    def move_button
      button(t('Move'), nil, class: "ajaxbox", href: url_for(action: "move_dialog", id: resource.id))
    end

  end
end
