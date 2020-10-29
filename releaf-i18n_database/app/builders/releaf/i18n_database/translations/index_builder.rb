module Releaf::I18nDatabase::Translations
  class IndexBuilder < Releaf::Builders::IndexBuilder
    include Releaf::I18nDatabase::Translations::BuildersCommon

    def text_search_content
      search_only_blank_ui + super
    end

    def search_only_blank_ui
      search_field "only-blank" do
        [
          check_box_tag(:only_blank, 'true', params[:only_blank].present? ),
          label_tag(:only_blank, t("Only blank"))
        ]
      end
    end

    def footer_primary_tools
      [edit_button]
    end

    def footer_secondary_tools
      [export_button, import_button, import_form]
    end

    def import_button
      button(t("Import"), "upload", name: "import", class: "secondary")
    end

    def import_form
      form_tag(url_for(action: 'import'), multipart: true, class: 'import') do
        file_field_tag :import_file
      end
    end

    def edit_button
      button(t("Edit"), "edit", class: "primary", href: action_url(:edit))
    end

    def text_search_available?
      true
    end
  end
end
