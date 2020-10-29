class Releaf::Permissions::Page::HeaderBuilder < Releaf::Builders::Page::HeaderBuilder
  def items
    super + [profile_block, sign_out_form]
  end

  def profile_path
    url_for(action: 'edit', controller: "releaf/permissions/profile", only_path: true)
  end

  def profile_block
    tag(:a, class: "button profile", href: profile_path) do
      [tag(:span, profile_user_name, class: "name")]
    end
  end

  def user
    controller.user
  end

  def profile_user_name
    resource_title(user)
  end

  def sign_out_path
    url_for(action: 'destroy', controller: "/releaf/permissions/sessions", only_path: true)
  end

  def sign_out_form
    form_tag(sign_out_path, method: :delete, class: "sign-out") do
      tag(:button, class: "button only-icon", type: "submit", title: t('Sign out', scope: "admin.sessions")) do
        icon("power-off icon-header")
      end
    end
  end
end
