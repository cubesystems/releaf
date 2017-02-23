module Releaf::Builders::FormBuilder::Associations
  def relation_name(name)
    name.to_s.sub(/_id$/, '').to_sym
  end

  def association_reflector(reflection, fields)
    fields ||= resource_fields.association_attributes(reflection)
    Releaf::Builders::AssociationReflector.new(reflection, fields, sortable_column_name)
  end

  def reflect_on_association(association_name)
    object.class.reflect_on_association(association_name)
  end

  def releaf_association_fields(reflection, fields)
    reflector = association_reflector(reflection, fields)

    case reflector.macro
    when :has_many
      releaf_has_many_association(reflector)
    when :belongs_to
      releaf_belongs_to_association(reflector)
    when :has_one
      releaf_has_one_association(reflector)
    else
      raise 'not implemented'
    end
  end

  def releaf_belongs_to_association(reflector)
    releaf_has_one_or_belongs_to_association(reflector)
  end

  def releaf_has_one_association(reflector)
    object.send("build_#{reflector.name}") unless object.send(reflector.name).present?
    releaf_has_one_or_belongs_to_association(reflector)
  end

  def releaf_has_one_or_belongs_to_association(reflector)
    tag(:fieldset, class: "type-association", data: {name: reflector.name}) do
      tag(:legend, translate_attribute(reflector.name)) <<
      fields_for(reflector.name, object.send(reflector.name), relation_name: reflector.name, builder: self.class) do |builder|
        builder.releaf_fields(reflector.fields)
      end
    end
  end

  def releaf_has_many_association(reflector)
    tag(:section, releaf_has_many_association_attributes(reflector)) do
      [
        releaf_has_many_association_header(reflector),
        releaf_has_many_association_body(reflector),
        releaf_has_many_association_footer(reflector)
      ]
    end
  end

  def releaf_has_many_association_attributes reflector
    item_template = releaf_has_many_association_fields(reflector, reflector.klass.new, '_template_', true)
    {
      class: "nested",
      data: { name: reflector.name, "releaf-template" => html_escape(item_template.to_str) }
    }
  end

  def releaf_has_many_association_header(reflector)
    tag(:header) do
      tag(:h1, translate_attribute(reflector.name))
    end
  end

  def releaf_has_many_association_body(reflector)
    attributes = {
      class: ["body", "list"]
    }
    attributes["data"] = {sortable: nil} if reflector.sortable?

    tag(:div, attributes) do
      association_collection(reflector).each_with_index.map do |association_object, index|
        releaf_has_many_association_fields(reflector, association_object, index, reflector.destroyable?)
      end
    end
  end

  def releaf_has_many_association_footer(_reflector)
    tag(:footer){ field_type_add_nested }
  end

  def releaf_has_many_association_fields(reflector, association_object, association_index, destroyable)
    tag(:fieldset, class: ["item", "type-association"], data: {name: reflector.name, index: association_index}) do
      fields_for(reflector.name, association_object, relation_name: reflector.name,
                 child_index: association_index, builder: self.class) do |builder|
        builder.releaf_has_many_association_field(reflector, destroyable)
      end
    end
  end

  def releaf_has_many_association_field(reflector, destroyable)
    content = ActiveSupport::SafeBuffer.new
    skippable_fields = []

    if reflector.sortable?
      skippable_fields << sortable_column_name
      content << hidden_field(sortable_column_name.to_sym, class: "item-position")
      content << tag(:div, "&nbsp;".html_safe, class: "handle")
    end

    content << releaf_fields(reflector.fields - skippable_fields)
    content << field_type_remove_nested if destroyable

    content
  end

  def releaf_item_field_choices(name, options = {})
    if options.key? :select_options
      options[:select_options]
    else
      releaf_item_field_collection(name, options).collect{|item| [resource_title(item), item.id]}
    end
  end

  def releaf_item_field_collection(name, options = {})
    options[:collection] || object.class.reflect_on_association(relation_name(name)).try(:klass).try(:all)
  end

  def releaf_item_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    label_options = {translation_key: name.to_s.sub(/_id$/, '').to_s}
    attributes = input_attributes(name, {value: object.send(name)}.merge(input), options)
    options = {field: {type: "item"}, label: label_options}.deep_merge(options)


    # add empty value when validation exists, so user is forced to choose something
    unless options.key? :include_blank
      options[:include_blank] = true
      object.class.validators_on(name).each do |validator|
        next unless validator.is_a? ActiveModel::Validations::PresenceValidator
        # if new record, or object is missing (was deleted)
        options[:include_blank] = object.new_record? || object.send(relation_name(name)).blank?
        break
      end
    end


    choices = releaf_item_field_choices(name, options)
    content = select(name, choices, options, attributes)
    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  def field_type_remove_nested
    button_attributes = {title: t('Remove'), class: "danger remove-nested-item"}
    wrapper(class: "remove-item-box") do
      button(nil, "trash-o", button_attributes) << hidden_field("_destroy", class: "destroy")
    end
  end

  def field_type_add_nested
    button(t('Add item'), "plus", class: "primary add-nested-item")
  end
end
