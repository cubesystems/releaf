module Releaf::I18nDatabase
  class TranslationEditBuilder < Releaf::Builders::EditBuilder

    def section
      tag(:section) do
        template.form_tag url_for( action: :update, search: template.params[:search] ) do
          safe_join do
            section_blocks
          end
        end
      end
    end

    def section_body
      tag(:div, class: "body") do
        template.render(partial: "form_fields")
      end
    end

    def import?
      template.instance_variable_get("@import")
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

    def export_button
      url = url_for(action: :export, search: params[:search], format: :xlsx)
      button(t('Export'), "download", class: "secondary", href: url)
    end

    def back_to_index_button
      url = url_for( action: :index, search: params[:search])
      button(t('Back to list', scope: 'admin.global'), "caret-left", class: "secondary", href: url)
    end

    def section_header; end
  end
end
