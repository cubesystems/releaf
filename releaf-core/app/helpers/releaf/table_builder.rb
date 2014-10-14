class Releaf::TableBuilder
  include Releaf::BuilderCommons
  attr_accessor :collection, :options, :template, :columns, :controller, :resource_class

  def initialize(collection, resource_class, template, options)
    self.collection = collection
    self.options = options
    self.template = template
    self.controller = template.controller
    self.resource_class = resource_class
    self.columns = {}
    build_columns
  end

  def build_columns
    if options[:toolbox] == true
      columns[:toolbox] = {cell_method: "toolbox_cell"}
    end

    column_names.each do|column|
      columns[column] = {
        custom_content_method: custom_content_method(column),
      }
      columns[column][:content_method] = column_content_method(column) if columns[column][:custom_content_method].nil?
    end
  end

  def column_names
    resource_class_attributes(resource_class)
  end

  def table
    tag(:table, table_attributes) do
      if collection.empty?
        empty_body
      else
        head << body
      end
    end
  end

  def head
    tag(:thead) do
      tag(:tr) do
        content = ''
        columns.each_pair do|column, options|
          content << head_cell(column)
        end
        content.html_safe
      end
    end
  end

  def head_cell(column)
    tag(:th) do
      head_cell_content(column)
    end
  end

  def head_cell_content(column)
    unless column == :toolbox
      tag(:span) do
        I18n.t(column.to_s, scope: "activerecord.attributes.#{resource_class.name.underscore}")
      end
    end
  end

  def empty_body
    tag(:tr) do
      tag(:th) do
        tag(:div) do
          I18n.t("nothing_found", scope: "admin.global")
        end
      end
    end
  end

  def body
    tag(:tbody, class: "tbody") do
      collection.collect do|resource|
        row(resource)
      end.join.html_safe
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
    tag(:tr, row_attributes(resource)) do
      content = ''
      columns.each_pair do|column, options|
        if options[:cell_method]
          content << send(options[:cell_method], resource)
        else
          content << cell(resource, column, options.merge(url: row_url(resource)))
        end
      end
      content.html_safe
    end
  end

  def custom_content_method(column)
    method_name = "#{column}_content"
    if respond_to? method_name
      method_name
    else
      nil
    end
  end

  def cell_content(resource, column, options)
    tag(:span) do
      if options[:custom_content_method]
        send(options[:custom_content_method], resource)
      else
        send(options[:content_method], resource, column)
      end
    end
  end

  def format_longtext_content(resource, column)
    # TODO: add limit
    resource.send(column)
  end

  def format_text_content(resource, column)
    value = resource.send(column)
    if value.respond_to? :to_text
      value.to_text
    else
      value.to_s
    end
  end

  def format_boolean_content(resource, column)
    value = resource.send(column)
    I18n.t(value ? 'yes' : 'no', scope: 'admin.global')
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
    unless resource.send(column).blank?
      association_name = column.to_s.sub(/_uid$/, '')
      template.image_tag(resource.send(association_name).thumb('x16').url, alt: '')
    else
       ""
    end
  end

  def format_association_content(resource, column)
    format_text_content(resource, association_name(column))
  end

  def association_name(column)
    column.to_s.sub(/_id$/, '').to_sym
  end

  def column_content_method(column)
    column_type = resource_class.columns_hash[column.to_s].try(:type)

    if column_type == :integer && column =~ /_id$/ && resource_class.reflections[association_name(column)]
      :format_association_content
    elsif column_type == :string && column =~ /(thumbnail|image|photo|picture|avatar|logo|icon)_uid$/
      :format_image_content
    elsif column_type == :boolean
      :format_boolean_content
    elsif column_type == :date
      :format_date_content
    elsif column_type == :datetime
      :format_datetime_content
    elsif column_type == :text
      :format_longtext_content
    else
      :format_text_content
    end
  end

  def toolbox_cell(resource)
    tag(:td, class: "toolbox-cell") do
      template.toolbox(resource, index_url: controller.index_url)
    end
  end

  def cell(resource, column, options)
    tag(:td) do
      if options[:url].blank?
        cell_content(resource, column, options)
      else
        tag(:a, href: options[:url]) do
          cell_content(resource, column, options)
        end
      end
    end
  end

  def table_attributes
    {
      class: "table"
    }
  end

  def output
    table
  end

  def tag(*args, &block)
    template.content_tag(*args, &block)
  end
end
