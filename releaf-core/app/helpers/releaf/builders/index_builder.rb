class Releaf::Builders::IndexBuilder
  include Releaf::Builders::View

  attr_accessor :collection

  def initialize(template)
    super
    self.collection = template.instance_variable_get("@collection")
  end

  def header_extras
    search
  end

  def search_available?
    template.instance_variable_get("@searchable_fields").present?
  end

  def text_search
    tag(:div, class: "text-search") do
      tag(:div, class: "wrapper") do
        [
          tag(:input, "", name: "search", type: "text", value: template.params[:search], autofocus: true),
          button(nil, "search", type: "submit", title: t('Search', scope: 'admin.global'))
        ]
      end
    end
  end

  def extra_search
  end

  def search
    parts = [text_search]
    return if parts.empty?
    tag(:form, class: ["search", (search_available? ? 'has-text-search' : '')], action: url_for( controller: controller_name, action: "index" )) do
      [text_search, extra_search]
    end
    #return unless (template.instance_variable_get("@searchable_fields") || template.instance_variable_get("@breadcrumbs"))
#%form.search{class: (!@searchable_fields.blank?) ? 'has-text-search' : '', action: url_for( controller: controller_name, action: "index" )}
  #- if @searchable_fields.present?
    #.text-search
      #.wrapper
        #%input{name: "search", type: "text", value: params[:search], autofocus: true }
        #= releaf_button(nil, "search", type: "submit", title: t('Search', scope: 'admin.global'))
      #.clear
  #- if has_template? "_index.search.extras"
    #.extras.clearInside
      #= render partial: "index.search.extras"
      #= releaf_button(t('Filter', scope: 'admin.global'), "search", type: "submit", title: t('Search', scope: 'admin.global'))
  end

  def section_header_text
    t("all_title", scope: 'admin.global')
  end

  def section_header_extras
    return unless collection.respond_to? :total_entries
    tag(:span, class: "totals") do
      [collection.total_entries, t("resources_found", scope: 'admin.global')]
    end
  end

  def footer_primary_tools
    items = []
    items << resource_creation_button if feature_available? :create
    items << pagination if pagination?
    items
  end

  def pagination?
    collection.respond_to?(:page)
  end

  def pagination
    template.will_paginate( collection, class: "pagination", params: template.params.merge({ajax: nil}), renderer: "Releaf::PaginationRenderer::LinkRenderer", outer_window: 0, inner_window: 2 )
  end

  def resource_creation_button
    button(t('Create new resource', scope: 'admin.global'), "plus", class: "primary",
                                      href: url_for(controller: controller_name, action: "new"))
  end

  def footer_secondary_tools
    []
  end

  def section_body
    tag(:div, class: "body") do
      template.releaf_table(collection, template.resource_class, template.table_options)
    end
  end
end
