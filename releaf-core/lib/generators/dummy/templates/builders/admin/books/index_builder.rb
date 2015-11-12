module Admin::Books
  class IndexBuilder < Releaf::Builders::IndexBuilder

    def extra_search_content
      tag(:div, class: "search-field-wrapper") do
        [check_box_tag(:only_active, 'true', params['only_active'].present?), label_tag(:only_active, t("Only active"))]
      end
    end
  end
end
