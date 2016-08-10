class Releaf::Builders::ConfirmDialogBuilder
  include Releaf::Builders::ResourceDialog

  attr_accessor :form

  def output
    tag(:section, section_attributes) do
      form_for(resource, confirm_form_options) do |form|
        self.form = form
        safe_join do
          section_blocks
        end
      end
    end
  end

  def section_body
    tag(:div, class: "body") do
      section_body_blocks
    end
  end

  def section_body_blocks
    [
      icon(icon_name),
      tag(:div, question_content, class: "question"),
      tag(:div, description_content, class: "description")
    ]
  end

  def section_attributes
    merge_attributes(super, class: ["confirm"])
  end

  def footer_primary_tools
    [cancel_button, confirm_button]
  end

  def confirm_form_options
    {builder: Releaf::Builders::FormBuilder, url: confirm_url, as: :resource, method: confirm_method}
  end

  def confirm_button
    button(t("Yes"), "check", class: "danger", type: 'submit')
  end

  def cancel_path
    index_path
  end

  def cancel_button
    button(t("No"), "ban", class: "secondary", data: {type: 'cancel'}, href: cancel_path)
  end
end
