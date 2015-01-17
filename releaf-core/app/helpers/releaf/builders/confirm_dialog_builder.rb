class Releaf::Builders::ConfirmDialogBuilder
  include Releaf::Builders::View
  include Releaf::Builders::ResourceDialog

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
    [cancel_form, confirm_form]
  end

  def confirm_method
    :delete
  end

  def confirm_form
    form_for(resource, builder: Releaf::Builders::FormBuilder, url: confirm_url, as: :resource, method: confirm_method) do
      button(t('Yes', scope: 'admin.global'), "check", class: "danger", type: 'submit')
    end
  end

  def cancel_url
    index_url
  end

  def cancel_form
    form_for(resource, builder: Releaf::Builders::FormBuilder, url: cancel_url, as: :resource, method: :get) do
      button(t('No', scope: 'admin.global'), "ban", class: "secondary", data: {type: 'cancel'}, type: 'submit')
    end
  end
end
