class Releaf::ConfirmDestroyDialogBuilder
  include Releaf::DialogBuilder

  def section_body
    tag(:div, class: "body") do
      [
        template.fa_icon("trash-o"),
        tag(:div, t('Confirm destroy', scope: 'admin.global'), class: "question"),
        tag(:div, template.resource_to_text(resource), class: "description")
      ]
    end
  end

  def footer_primary_tools
    [cancel_form, confirm_form]
  end

  def cancel_form
    template.form_for(resource, builder: Releaf::FormBuilder, url: url_for( action: 'destroy', id: resource.id, index_url: index_url), as: :resource, method: :delete) do
      button(t('Yes', scope: 'admin.global'), "trash-o", class: "danger", data: {type: 'cancel'}, type: 'submit')
    end
  end

  def confirm_form
    template.form_for(resource, builder: Releaf::FormBuilder, url: index_url, as: :resource, method: :get) do
      button(t('No', scope: 'admin.global'), "ban", class: "secondary", data: {type: 'cancel'}, type: 'submit')
    end
  end

  # TODO
  def section_header
  end
end
