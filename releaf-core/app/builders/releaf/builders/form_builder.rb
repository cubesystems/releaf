class Releaf::Builders::FormBuilder < ActionView::Helpers::FormBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::FormBuilder::Label
  include Releaf::Builders::FormBuilder::Fields
  include Releaf::Builders::FormBuilder::Associations
  attr_accessor :template

  def field_names
    resource_fields.values
  end

  def resource_fields
    Releaf::ResourceFields.new(object.class)
  end

  def field_render_method_name(name)
    parts = [name]

    builder = self
    until builder.options[:parent_builder].nil? do
      parts << builder.options[:relation_name] if builder.options[:relation_name]
      builder = builder.options[:parent_builder]
    end

    parts << "render"
    parts.reverse.join("_")
  end

  def normalize_fields(fields)
    fields.flatten.map do |item|
      if item.is_a? Hash
        item.each_pair.map do |(association, subfields)|
          normalize_field(association, subfields)
        end
      else
        normalize_field(item, nil)
      end
    end.flatten
  end

  def normalize_field(field, subfields)
    {
      render_method: field_render_method_name(field),
      field: field,
      subfields: subfields
    }
  end

  def releaf_fields(*fields)
    safe_join do
      normalize_fields(fields).collect{|field_option| render_field_by_options(field_option) }
    end
  end

  def render_field_by_options(options)
    if respond_to? options[:render_method]
      send(options[:render_method])
    else
      reflection = reflect_on_association(options[:field])

      if reflection
        releaf_association_fields(reflection, options[:subfields])
      else
        releaf_field(options[:field])
      end
    end
  end

  def field_type_method(name)
    Releaf::Builders::Utilities::ResolveAttributeFieldMethodName.call(object: object, attribute_name: name.to_s)
  end

  def releaf_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    method_name = field_type_method(name)
    send(method_name, name, input: input, label: label, field: field, options: options, &block)
  end

  def input_wrapper_with_label(name, input_content, label: {}, field: {}, options: {})
    field(name, field, options) do
      input_content = safe_join{[input_content, yield.to_s]} if block_given?
      releaf_label(name, label, options) << wrapper(input_content, class: "value")
    end
  end

  def field(name, attributes, options, &block)
    tag(:div, field_attributes(name, attributes, options), nil, nil, &block)
  end

  def field_attributes(name, attributes, options)
    type = options.fetch(:field, {}).fetch(:type, nil)

    classes = ["field", "type-#{type}"]
    classes << "i18n" if options.key? :i18n

    merge_attributes({class: classes, data: {name: name.to_s}}, attributes)
  end

  def input_attributes(_name, attributes, _options)
    attributes
  end

  def translate_attribute(attribute)
    object.class.human_attribute_name(attribute)
  end

  def association_collection(reflector)
    object.send(reflector.name)
  end

  def sortable_column_name
    'item_position'
  end
end
