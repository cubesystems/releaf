class Releaf::Builders::ConfirmDialogBuilder
  include Releaf::Builders::View
  include Releaf::Builders::ResourceDialog

  attr_accessor :form

  def output
    tag(:section, class: classes) do
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

  def classes
    super << "confirm"
  end

  def footer_primary_tools
    [cancel_button, confirm_button]
  end

  def confirm_form_options
    {builder: Releaf::Builders::FormBuilder, url: confirm_url, as: :resource, method: confirm_method}
  end

  def confirm_button
    button(t('Yes', scope: 'admin.global'), "check", class: "danger", type: 'submit')
  end

  def cancel_url
    index_url
  end

  def cancel_button
    button(t('No', scope: 'admin.global'), "ban", class: "secondary", data: {type: 'cancel'}, href: index_url)
  end
end
