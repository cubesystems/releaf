class Releaf::Builders::IndexBuilder
  include Releaf::Builders::View
  include Releaf::Builders::Collection

  def header_extras
    search_block if feature_available?(:search)
  end

  def dialog?
    false
  end

  def text_search_available?
    controller.searchable_fields.present?
  end

  def extra_search_available?
    extra_search_block.present?
  end

  def text_search_block
    return unless text_search_available?
    tag(:div, class: "text-search"){ text_search_content }
  end

  def text_search_content
    search_field "search" do
      [
        tag(:input, "", name: "search", type: "search", class: "text", value: params[:search], autofocus: true),
        button(nil, "search", type: "submit", title: t('Search'))
      ]
    end
  end

  def search_field( name )
    tag(:div, class: "search-field", data: { name: name } ) do
      yield
    end
  end


  def extra_search_content; end

  def extra_search_button
    button(t("Filter"), "search", type: "submit", title: t("Search"))
  end

  def extra_search_block
    if @extra_search
      @extra_search
    else
      content = extra_search_content
      @extra_search = tag(:div, class: ["extras"]){ [content, extra_search_button] } if content.present?
    end
  end

  def search_block
    parts = [text_search_block, extra_search_block].compact
    tag(:form, search_form_attributes){ parts } if parts.present?
  end

  def search_form_attributes
    classes = ["search"]
    classes << "has-text-search" if text_search_available?
    classes << "has-extra-search" if extra_search_available?
    url = url_for(controller: controller_name, action: "index")

    {class: classes, action: url}
  end

  def section_header_text
    t("All resources")
  end

  def section_header_extras
    return unless collection.respond_to? :total_entries
    tag(:span, class: "extras totals only-text") do
      t("Resources found", count: collection.total_entries, default: "%{count} resources found", create_plurals: true)
    end
  end

  def footer_blocks
    list = [footer_primary_block]
    list << pagination_block if pagination?
    list << footer_secondary_block
    list
  end

  def footer_primary_tools
    items = []
    items << resource_creation_button if feature_available?(:create)
    items
  end

  def pagination?
    collection.respond_to?(:page)
  end

  def pagination_builder_class
    Releaf::Builders::PaginationBuilder
  end

  def pagination_block
    pagination_builder_class.new(template, collection: collection, params: params).output
  end

  def resource_creation_button
    url = url_for(controller: controller_name, action: "new")
    text = t("Create new resource")
    button(text, "plus", class: "primary", href: url)
  end

  def table_options
    {
      builder: builder_class(:table),
      toolbox: feature_available?(:toolbox)
    }
  end

  def section_body
    tag(:div, class: "body") do
      template.releaf_table(collection, template.resource_class, table_options)
    end
  end
end
