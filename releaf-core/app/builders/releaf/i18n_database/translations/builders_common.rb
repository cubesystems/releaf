module Releaf
  module I18nDatabase
    module Translations
      module BuildersCommon
        def export_button
          url = url_for(action: :export, search: params[:search], format: :xlsx)
          button(t("export"), "download", class: "secondary", href: url)
        end
      end
    end
  end
end
