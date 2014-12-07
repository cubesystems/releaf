class Releaf::Builders::IndexBuilder
  include Releaf::Builders::View
  include Releaf::Builders::Collection

  def header_extras
    search
  end

  def text_search_available?
    template_variable("searchable_fields").present?
  end

  def text_search
    return unless text_search_available?
    tag(:div, class: "text-search") do
      text_search_content
    end
  end

  def text_search_content
    [tag(:input, "", name: "search", type: "text", value: params[:search], autofocus: true),
      button(nil, "search", type: "submit", title: t('Search', scope: 'admin.global'))]
  end

  def extra_search_content; end

  def extra_search_button
    button(t('Filter', scope: 'admin.global'), "search", type: "submit", title: t('Search', scope: 'admin.global'))
  end

  def extra_search
    content = extra_search_content
    return unless content.present?
    tag(:div, class: "extras") do
      [content, extra_search_button]
    end
  end

  def search
    parts = [text_search, extra_search_content].compact
    return if parts.empty?

    url = url_for( controller: controller_name, action: "index" )
    tag(:form, class: ["search clearInside", (text_search_available? ? 'has-text-search' : '')], action: url) do
      parts
    end
  end

  def section_header_text
    t("all_title", scope: 'admin.global')
  end

  def section_header_extras
    return unless collection.respond_to? :total_entries
    tag(:span, class: "totals") do
      "#{collection.total_entries} #{t("resources_found", scope: 'admin.global')}"
    end
  end

  def footer_blocks
    list = [footer_primary_block]
    list << pagination if pagination?
    list << footer_secondary_block
    list
  end

  def footer_primary_tools
    items = []
    items << resource_creation_button if feature_available? :create
    items
  end

  def pagination?
    collection.respond_to?(:page)
  end

  def pagination
    template.will_paginate( collection, class: "pagination", params: params.merge({ajax: nil}), renderer: "Releaf::PaginationRenderer::LinkRenderer", outer_window: 0, inner_window: 2 )
  end

  def resource_creation_button
    button(t('Create new resource', scope: 'admin.global'), "plus", class: "primary",
                                      href: url_for(controller: controller_name, action: "new"))
  end

  def section_body
    tag(:div, class: "body") do
      template.releaf_table(collection, template.resource_class, template.table_options)
    end
  end
end
