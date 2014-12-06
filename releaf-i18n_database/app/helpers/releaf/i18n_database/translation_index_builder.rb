module Releaf::I18nDatabase
  class TranslationIndexBuilder < Releaf::Builders::IndexBuilder

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

#%form.search.has-text-search{ action: url_for( controller: controller_name, action: "index" )}
  #.text-search
    #.wrapper
      #.search-field-wrapper.search-only-bank
        #= check_box_tag :only_blank, 'true', params['only_blank'] == 'true'
        #= label_tag :only_blank, I18n.t("Only blank", scope: controller_scope_name)
      #.search-field-wrapper.search-text
        #%input{name: "search", type: "text", value: params[:search], autofocus: true }
        #= releaf_button(nil, "search", type: "submit", title: t('Search', scope: 'admin.global'))
      #.clear
    #.clear

