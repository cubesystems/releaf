class Releaf::Builders::PageHeaderBuilder
  include Releaf::Builders::Base
  attr_accessor :template

  def initialize(template)
    self.template = template
  end

  def output
    safe_join do
      items
    end
  end

  def items
    [home_link, profile_block, sign_out_form]
  end

  def home_link
    tag(:a, "", class: "brand", href: home_url)
  end

  def home_url
    url_for(action: 'index', controller: "/releaf/home")
  end

  def profile_url
    url_for(action: 'edit', controller: profile_controller)
  end

  def profile_settings_url
    url_for(action: 'settings', controller: profile_controller)
  end

  def profile_controller
    "/releaf/permissions/profile"
  end

  def profile_block
    tag(:a, class: "profile", href: profile_url, "data-settings-url" => profile_settings_url) do
      [tag(:span, profile_user_name, class: "name"), profile_user_image]
    end
  end

  def profile_user_image
    template.gravatar_image_tag(current_admin_user.email, alt: profile_user_name,
                                gravatar: { size: 36, secure: request.ssl?, default: 'mm' }, class: "avatar")
  end

  def profile_user_name
    current_admin_user.to_text
  end

  def sign_out_url
    url_for(action: 'destroy', controller: "/releaf/sessions")
  end

  def sign_out_form
    form_tag(sign_out_url, method: :delete, class: "sign-out") do
      tag(:button, type: "submit") do
        fa_icon("power-off icon-header")
      end
    end
  end
end