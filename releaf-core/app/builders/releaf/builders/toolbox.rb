module Releaf::Builders::Toolbox
  def toolbox(resource, extra_params = {})
    return '' if resource.new_record?

    url = url_for({action: :toolbox, id: resource.id, context: action_name}.merge(extra_params))

    tag(:div, class: "toolbox uninitialized", data: {url: url}) do
      [toolbox_button, toolbox_menu]
    end
  end

  def toolbox_menu
    tag(:menu, class: %w(block toolbox-items), type: "toolbar") do
      [icon("caret-up lg"), tag(:ul, "", class: "block")]
    end
  end

  def toolbox_button
    tag(:button, disabled: "disabled", class: %w(button trigger only-icon), type: "button", title: t("Tools")) do
      icon("cog lg")
    end
  end
end
