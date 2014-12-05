module Releaf::Content
  class NodeToolboxBuilder < Releaf::Builders::ToolboxBuilder
    def items
      list = []

      unless resource.new_record?
        list << add_child_button
        list << go_to_button unless template.params[:context] == "index"
        list << copy_button
        list << move_button
      end

      list + super
    end

    def add_child_button
      button(t('Add child'), "plus lg", class: "ajaxbox", href: url_for(action: "new", parent_id: resource.id))
    end

    def go_to_button
      button(t('Go to'), "external-link lg", class: "ajaxbox", href: url_for(action: "go_to_dialog"))
    end

    def copy_button
      button(t('Copy'), "copy lg", class: "ajaxbox", href: url_for(action: "copy_dialog", id: resource.id))
    end

    def move_button
      button(t('Move'), "arrows lg", class: "ajaxbox", href: url_for(action: "move_dialog", id: resource.id))
    end

  end
end
