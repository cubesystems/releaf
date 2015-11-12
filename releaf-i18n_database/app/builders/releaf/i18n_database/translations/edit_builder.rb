module Releaf::I18nDatabase::Translations
  class EditBuilder < Releaf::Builders::EditBuilder
    include Releaf::I18nDatabase::Translations::BuildersCommon

    def section
      tag(:section) do
        form_tag(action_url(:update)) do
          safe_join{ section_blocks }
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
      button(save_button_text, "check", class: "primary", data: { type: 'ok' }, type: "submit")
    end

    def save_button_text
      t(import? ? "Import" : "Save")
    end

    def footer_secondary_tools
      [back_to_index_button, (export_button unless import?)].compact
    end

    def back_to_index_button
      button(t("Back to list"), "caret-left", class: "secondary", href: action_url(:index))
    end

    def section_header; end
  end
end
