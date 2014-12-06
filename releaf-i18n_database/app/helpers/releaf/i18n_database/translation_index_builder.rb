module Releaf::I18nDatabase
  class TranslationIndexBuilder < Releaf::Builders::IndexBuilder

    def text_search_content
      [search_only_blank_ui] + super
    end

    def search_only_blank_ui
      tag(:div, class: "search-field-wrapper search-only-blank") do
        [template.check_box_tag(:only_blank, 'true', params['only_blank'] == 'true'),
         template.label_tag(:only_blank, t("Only blank"))]
      end
    end

    def footer_primary_tools
      [edit_button, pagination]
    end

    def footer_secondary_tools
      [export_button, import_button, import_form]
    end

    def export_button
      url = url_for(action: :export, search: template.params[:search], format: :xlsx)
      button(t("export"), "download", class: "secondary", href: url)
    end

    def import_button
      button(t("import"), "upload", name: "import", class: "secondary")
    end

    def import_form
      form_attributes = {multipart: true, id: nil, class: 'import', style: 'display:none', method: :post}
      template.form_tag(url_for(action: 'import'), form_attributes) do
        template.file_field_tag :import_file
      end
    end

    def edit_button
      url = url_for(action: :edit, search: template.params[:search])
      button(t('Edit', scope: 'admin.global'), "edit", class: "edit", class: "primary", href: url)
    end
  end
end
