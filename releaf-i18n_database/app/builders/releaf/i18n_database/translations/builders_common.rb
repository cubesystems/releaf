module Releaf::I18nDatabase::Translations
  module BuildersCommon

    def action_url(action, params = {})
      url_for(request.query_parameters.merge(action: action).merge(params))
    end

    def export_button
      url = action_url(:export, format: :xlsx)
      button(t("Export"), "download", class: "secondary", href: url)
    end
  end
end
