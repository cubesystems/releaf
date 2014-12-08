class Releaf::Builders::TableBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::ResourceClass

  attr_accessor :collection, :options, :template, :resource_class

  def initialize(collection, resource_class, template, options)
    self.collection = collection
    self.options = options
    self.template = template
    self.resource_class = resource_class
  end

  def column_names
    resource_class_attributes(resource_class)
  end

  def columns
    @columns ||= columns_schema
  end

  def columns_schema
    data = {}

    final_column_names = []
    final_column_names << :toolbox if options[:toolbox] == true
    final_column_names += column_names

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
    {class: "table"}
  end

  def head
    tag(:thead) do
      tag(:tr) do
        content = ActiveSupport::SafeBuffer.new
        columns.each_pair do|column, options|
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
      tag(:span) do
        I18n.t(column.to_s, scope: "activerecord.attributes.#{resource_class.name.underscore}")
      end
    end
  end

  def empty_body
    tag(:tr) do
      tag(:th) do
        tag(:div, class: "nothing-found") do
          I18n.t("nothing found", scope: translation_scope)
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
    template.try(:resource_edit_url, resource)
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
    tag(:span) do
      if options[:content_method]
        send(options[:content_method], resource)
      else
        send(options[:format_method], resource, column)
      end
    end
  end

  def format_text_content(resource, column)
    value = resource.send(column).to_s
    truncate(value, length: 32, separator: ' ')
  end

  def format_string_content(resource, column)
    value = resource.send(column)
    if value.respond_to? :to_text
      value.to_text
    else
      value.to_s
    end
  end

  def format_boolean_content(resource, column)
    value = resource.send(column)
    I18n.t(value == true ? 'yes' : 'no', scope: translation_scope)
  end

  def format_date_content(resource, column)
    value = resource.send(column)
    I18n.l(value, format: :default, default: '%Y-%m-%d') unless value.nil?
  end

  def format_datetime_content(resource, column)
    value = resource.send(column)
    I18n.l(value, format: :default, default: '%Y-%m-%d %H:%M:%S') unless value.nil?
  end

  def format_image_content(resource, column)
    if resource.send(column).present?
      association_name = column.to_s.sub(/_uid$/, '')
      image_tag(resource.send(association_name).thumb('x16').url, alt: '')
    end
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

  def column_type(column)
    column_description = resource_class.columns_hash[column.to_s]
    if column_description
      column_description.type
    else
      :string
    end
  end

  def column_type_format_method(column)
    format_method = "format_#{column_type(column)}_content".to_sym
    if respond_to?(format_method)
      format_method
    else
      :format_string_content
    end
  end

  def cell_format_method(column)
    if association_column?(column)
      :format_association_content
    elsif image_column?(column)
      :format_image_content
    else
      column_type_format_method(column)
    end
  end

  def image_column?(column)
    column =~ /(thumbnail|image|photo|picture|avatar|logo|icon)_uid$/
  end

  def association_column?(column)
    column =~ /_id$/ && resource_class.reflections[association_name(column)]
  end

  def toolbox_cell(resource, options)
    tag(:td, class: "toolbox-cell") do
      toolbox(resource, index_url: controller.index_url)
    end
  end

  def cell(resource, column, options)
    content = cell_content(resource, column, options)

    tag(:td) do
      if options[:url].blank?
        content
      else
        tag(:a, href: options[:url]) do
          content
        end
      end
    end
  end

  def translation_scope
    "admin.global"
  end
end
