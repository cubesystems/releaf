module Releaf::Builders::Toolbox
  def toolbox(resource, extra_params = {})
    return '' if resource.new_record?

    url = url_for({action: :toolbox, id: resource.id, context: action_name}.merge(extra_params))

    tag(:div, class: "toolbox", data: {url: url}) do
      [toolbox_button, toolbox_menu]
    end
  end

  def toolbox_menu
    tag(:menu, class: %w(toolbox-items), type: "toolbar") do
      [icon("caret-up"), tag(:ul, "")]
    end
  end

  def toolbox_button
    tag(:button, class: %w(button trigger only-icon), type: "button", title: t("Tools")) do
      icon("ellipsis-v")
    end
  end
end
