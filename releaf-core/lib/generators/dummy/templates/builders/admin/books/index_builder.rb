module Admin::Books
  class IndexBuilder < Releaf::Builders::IndexBuilder

    def extra_search_content
      active_search_field + publishing_date_search_fields
    end

    def active_search_field
      search_field :only_active do
        [
          check_box_tag(:only_active, 'true', params['only_active'].present?),
          label_tag(:only_active, t("Only active"))
        ]
      end
    end

    def publishing_date_search_fields
      search_field :published_between do
        [
          tag(:label, t('Published between'), for: "search_published_since" ),
          tag(:input, "", name: "published_since", type: "date", class: "text date-picker", value: params[:published_since], id: "search_published_since"),
          tag(:label, t('and'), for: "search_published_up_to" ),
          tag(:input, "", name: "published_up_to", type: "date", class: "text date-picker", value: params[:published_up_to], id: "search_published_up_to")
        ]
      end
    end

  end
end

