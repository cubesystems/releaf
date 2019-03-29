class Releaf::Builders::TableBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::Toolbox
  attr_accessor :collection, :options, :template, :resource_class

  def initialize(collection, resource_class, template, options)
    self.collection = collection
    self.options = options
    self.template = template
    self.resource_class = resource_class
  end

  def column_names
    Releaf::ResourceTableFields.new(resource_class).values(include_associations: false)
  end

  def columns
    @columns ||= columns_schema
  end

  def columns_schema
    data = {}

    final_column_names = []
    final_column_names += column_names
    final_column_names << :toolbox if options[:toolbox] == true

    final_column_names.map do|column|
      if cell_method(column)
        data[column] = {cell_method: cell_method(column)}
      elsif cell_content_method(column)
        data[column] = {content_method: cell_content_method(column)}
      else
        data[column] = {format_method: cell_format_method(column)}
      end
    end

    data
  end

  def output
    tag(:table, table_attributes) do
      if collection.empty?
        empty_body
      else
        head << body
      end
    end
  end

  def table_attributes
    {class: ["table", resource_class.name.pluralize.underscore.dasherize]}
  end

  def head
    tag(:thead) do
      tag(:tr) do
        content = ActiveSupport::SafeBuffer.new
        columns.each_pair do|column, _options|
          content << head_cell(column)
        end
        content
      end
    end
  end

  def head_cell(column)
    tag(:th) do
      head_cell_content(column)
    end
  end

  def head_cell_content(column)
    unless column.to_sym == :toolbox
      attribute = column.to_s.tr(".", "_")
      resource_class.human_attribute_name(attribute)
    end
  end

  def empty_body
    tag(:tr) do
      tag(:th) do
        tag(:div, class: "nothing-found") do
          t("Nothing found")
        end
      end
    end
  end

  def body
    tag(:tbody, class: "tbody") do
      collection.collect do |resource|
        row(resource)
      end
    end
  end

  def row_url(resource)
    resource_action = row_url_action(resource)
    url_for(action: resource_action, id: resource.id, index_path: index_path) if resource_action
  end

  def row_url_action(_resource)
    if feature_available?(:show)
      :show
    elsif feature_available?(:edit)
      :edit
    end
  end

  def row_attributes(resource)
    {
      class: "row",
      data: {
        id: resource.id
      }
    }
  end

  def row(resource)
    url = row_url(resource)
    tag(:tr, row_attributes(resource)) do
      content = ActiveSupport::SafeBuffer.new
      columns.each_pair do|column, options|
        cell_options = options.merge(url: url)
        if options[:cell_method]
          content << send(options[:cell_method], resource, cell_options)
        else
          content << cell(resource, column, cell_options)
        end
      end
      content
    end
  end

  def cell_content(resource, column, options)
    if options[:content_method]
      send(options[:content_method], resource)
    else
      send(options[:format_method], resource, column)
    end
  end

  def format_text_content(resource, column)
    truncate(column_value(resource, column).to_s, length: 32, separator: ' ')
  end

  def format_textarea_content(resource, column)
    format_text_content(resource, column)
  end

  def format_richtext_content(resource, column)
    value = ActionView::Base.full_sanitizer.sanitize(column_value(resource, column).to_s)
    truncate(value, length: 32, separator: ' ')
  end

  def format_string_content(resource, column)
    value = column_value(resource, column)
    resource_title(value)
  end

  def format_boolean_content(resource, column)
    t(column_value(resource, column) == true ? "Yes" : "No")
  end

  def format_date_content(resource, column)
    value = column_value(resource, column)
    I18n.l(value, format: :default) unless value.nil?
  end

  def format_datetime_content(resource, column)
    value = column_value(resource, column)
    format = Releaf::Builders::Utilities::DateFields.date_or_time_default_format(:datetime)
    I18n.l(value, format: format) unless value.nil?
  end


  def format_time_content(resource, column)
    value = column_value(resource, column)
    format = Releaf::Builders::Utilities::DateFields.date_or_time_default_format(:time)
    I18n.l(value, format: format) unless value.nil?
  end

  def format_association_content(resource, column)
    format_string_content(resource, association_name(column))
  end

  def association_name(column)
    column.to_s.sub(/_id$/, '').to_sym
  end

  def cell_method(column)
    method_name = "#{column}_cell"
    if respond_to? method_name
      method_name
    else
      nil
    end
  end

  def cell_content_method(column)
    method_name = "#{column}_content"
    if respond_to? method_name
      method_name
    else
      nil
    end
  end

  def column_type(klass, column)
    column_description = klass.columns_hash[column.to_s]
    if column_description
      column_description.type
    else
      :string
    end
  end

  def column_type_format_method(column)
    klass = column_klass(resource_class, column)
    type = column_type(klass, column)

    type_format_method(type)
  end

  def type_format_method(type)
    format_method = "format_#{type}_content".to_sym

    if respond_to?(format_method)
      format_method
    else
      :format_string_content
    end
  end

  def column_klass(klass, column)
    column.to_s.split(".")[0..-2].each do|part|
      reflection = klass.reflect_on_association(part)
      klass = reflection.klass if reflection
    end

    klass
  end

  def column_value(resource_or_value, column)
    column.to_s.split(".").each do|part|
      resource_or_value = resource_or_value.send(part) if resource_or_value.present?
    end

    resource_or_value
  end

  def cell_format_method(column)
    if association_column?(column)
      :format_association_content
    else
      column_type_format_method(column)
    end
  end

  def association_column?(column)
    !!(column =~ /_id$/) && resource_class.reflections[association_name(column).to_s].present?
  end

  def toolbox_cell(resource, options)
    toolbox_args = {index_path: index_path}.merge(options.fetch(:toolbox, {}))
    tag(:td, class: "only-icon toolbox-cell") do
      toolbox(resource, toolbox_args)
    end
  end

  def cell(resource, column, options)
    content = cell_content(resource, column, options)

    tag(:td) do
      if options[:url].blank?
        tag(:span) do
          content
        end
      else
        tag(:a, href: options[:url]) do
          content
        end
      end
    end
  end
end
