module Releaf::Content::Nodes
  class EditBuilder < Releaf::Builders::EditBuilder
    def section_body
      tag(:div, class: "body") do
        [error_notices, form_fields]
      end
    end

    def form_fields
      render(partial: "form_fields", locals: {form: form, object: form.object})
    end
  end
end
