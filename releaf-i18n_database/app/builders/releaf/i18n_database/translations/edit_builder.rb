module Releaf::I18nDatabase::Translations
  class EditBuilder < Releaf::Builders::EditBuilder
    include Releaf::I18nDatabase::Translations::BuildersCommon

    def section
      tag(:section) do
        form_tag url_for( action: :update, search: params[:search] ) do
          safe_join do
            section_blocks
          end
        end
      end
    end

    def section_body
      tag(:div, class: "body") do
        render partial: "form_fields", locals: {builder: self}
      end
    end

    def import?
      template_variable("import")
    end

    def save_button
      if import?
        button_text =  t('Import')
      else
        button_text =  t('Save', scope: "admin.global")
      end

      button(button_text, "check", class: "primary", data: { type: 'ok' }, type: "submit")
    end

    def footer_secondary_tools
      [back_to_index_button, (export_button unless import?)]
    end

    def back_to_index_button
      url = url_for( action: :index, search: params[:search])
      button(t('Back to list', scope: 'admin.global'), "caret-left", class: "secondary", href: url)
    end

    def section_header; end
  end
end
