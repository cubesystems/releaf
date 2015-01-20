class Releaf::Builders::FormBuilder < ActionView::Helpers::FormBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::ResourceClass

  attr_accessor :template

  def field_names
    resource_class_attributes(object.class)
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
      association: object.class.reflections.key?(field.to_sym),
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
    elsif options[:association] == true
      releaf_association_fields(options[:field], options[:subfields])
    else
      releaf_field(options[:field])
    end
  end

  def reflection(reflection_name)
    object.class.reflections[reflection_name.to_sym]
  end

  def association_fields(association_name)
    reflection = reflection(association_name)
    resource_class_attributes(reflection.klass) - [reflection.foreign_key]
  end

  def releaf_association_fields(association_name, fields)
    fields = association_fields(association_name) if fields.nil?

    case reflection(association_name).macro
    when :has_many
      releaf_has_many_association(association_name, fields)
    when :belongs_to
      releaf_belongs_to_association(association_name, fields)
    when :has_one
      releaf_has_one_association(association_name, fields)
    else
      raise 'not implemented'
    end
  end

  def releaf_belongs_to_association(association_name, fields)
    releaf_has_one_or_belongs_to_association(association_name, fields)
  end

  def releaf_has_one_association(association_name, fields)
    object.send("build_#{association_name}") unless object.send(association_name).present?
    releaf_has_one_or_belongs_to_association(association_name, fields)
  end

  def releaf_has_one_or_belongs_to_association(association_name, fields)
    tag(:fieldset, class: "type-association", data: {name: association_name}) do
      tag(:legend, t(association_name)) <<
      fields_for(association_name, object.send(association_name), relation_name: association_name, builder: self.class) do |builder|
        builder.releaf_fields(fields)
      end
    end
  end

  def releaf_has_many_association(association_name, fields)
    reflection = reflection(association_name)
    sortable_objects = reflection.klass.column_names.include?(sortable_column_name)

    item_template = releaf_has_many_association_fields(association_name, obj: reflection.klass.new, child_index: '_template_', allow_destroy: true,
                                             sortable_objects: sortable_objects, subfields: fields)
    item_template = html_escape(item_template.to_str) # make html unsafe and escape afterwards

    tag(:section, class: "nested", data: {name: association_name, "releaf-template" => item_template}) do
      [releaf_has_many_association_header(association_name),
       releaf_has_many_association_body(association_name, sortable_objects, reflection, fields),
       releaf_has_many_association_footer(association_name)]
    end
  end

  def releaf_has_many_association_header(association_name)
    tag(:header) do
      tag(:h1, t(association_name))
    end
  end

  def releaf_has_many_association_body(association_name, sortable_objects, reflection, fields)
    tag(:div, class: "body list", data: {sortable: sortable_objects ? '' : nil}) do
      allow_destroy = reflection.active_record.nested_attributes_options.fetch(reflection.name, {}).fetch(:allow_destroy, false)

      object.send(association_name).each_with_index.map do |obj, i|
        releaf_has_many_association_fields(association_name, obj: obj, child_index: i, allow_destroy: allow_destroy,
                                          sortable_objects: sortable_objects, subfields: fields)
        end
    end
  end

  def releaf_has_many_association_footer(association_name)
    tag(:footer) do
      field_type_add_nested
    end
  end

  def releaf_has_many_association_fields(association_name, obj: nil, subfields: nil, child_index: nil, allow_destroy: nil, sortable_objects: nil)
    tag(:fieldset, class: ["item", "type-association"], data: {name: association_name, index: child_index}) do
      fields_for(association_name, obj, relation_name: association_name, child_index: child_index, builder: self.class) do |builder|
        builder.releaf_has_many_association_field(association_name, sortable_objects, subfields, allow_destroy)
      end
    end
  end

  def releaf_has_many_association_field(field, sortable_objects, subfields, allow_destroy)
    content = ActiveSupport::SafeBuffer.new

    if sortable_objects
      content << hidden_field(sortable_column_name.to_sym, class: "item-position")
      content << tag(:div, "&nbsp;".html_safe, class: "handle")
    end

    content << releaf_fields(subfields)
    content << field_type_remove_nested if allow_destroy

    content
  end

  def field_type_remove_nested
    button_attributes = {title: t('Remove item'), class: "danger only-icon remove-nested-item"}
    wrapper(class: "remove-item-box") do
      button(nil, "trash-o lg", button_attributes) << hidden_field("_destroy", class: "destroy")
    end
  end

  def field_type_add_nested
    button(t('Add item'), "plus", class: "primary add-nested-item")
  end

  def field_type_method(name)
    type = Releaf::TemplateFieldTypeMapper.field_type_name(object, name)
    localization = Releaf::TemplateFieldTypeMapper.use_i18n?(object, name)

    "releaf_#{type}_#{'i18n_' if localization}field"
  end

  def releaf_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    method_name = field_type_method(name)
    send(method_name, name, input: input, label: label, field: field, options: options, &block)
  end

  def releaf_item_field_collection(name, options = {})
    options[:collection] || object.class.reflect_on_association(relation_name(name)).try(:klass).try(:all)
  end

  def releaf_item_field_choices(name, options = {})
    unless options.key? :select_options
      options[:select_options] = releaf_item_field_collection(name, options)
        .collect{|item| [resource_to_text(item), item.id]}
    end

    if options[:select_options].is_a? Array
      choices = options_for_select(options[:select_options], object.send(name))
    else
      choices = options[:select_options]
    end

    choices
  end

  def relation_name(name)
    name.to_s.sub(/_id$/, '').to_sym
  end

  def releaf_item_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    label = {translation_key: name.to_s.sub(/_id$/, '').to_s}.deep_merge(label)
    attributes = input_attributes(name, {value: object.send(name)}.merge(input), options)
    options = {field: {type: "item"}}.deep_merge(options)


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

  def releaf_image_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    name = name.to_s.sub(/_uid$/, '')

    attributes = {
      accept: 'image/png,image/jpeg,image/bmp,image/gif'
    }.merge(input)

    attributes = input_attributes(name, attributes, options)

    options = {field: {type: "image"}}.deep_merge(options)
    content = file_field(name, attributes)
    if object.send(name).present?
      content += tag(:div, class: "value-preview") do
        inner_content = tag(:div, class: "image-wrap") do
          thumbnail = image_tag(object.send(name).thumb('410x128>').url, alt: '')
          hidden_field("retained_#{name}") +
            link_to(thumbnail, object.send(name).url, target: :_blank, class: :ajaxbox, rel: :image)
        end
        inner_content << releaf_file_remove_button(name)
      end
    end

    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  def releaf_file_remove_button(name)
    tag(:div, class: "remove") do
      check_box("remove_#{name}") << label("remove_#{name}", t("Remove"))
    end
  end

  def releaf_file_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    name = name.to_s.sub(/_uid$/, '')
    attributes = input_attributes(name, input, options)
    options = {field: {type: "file"}}.deep_merge(options)

    content = file_field(name, attributes)
    if object.send(name).present?
      content << hidden_field("retained_#{name}")
      content << link_to(t("Download"), object.send(name).url, target: "_blank")
      content << releaf_file_remove_button(name)
    end

    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  def releaf_boolean_field(name, input: {}, label: {}, field: {}, options: {})
    attributes = input_attributes(name, input, options)
    options = {field: {type: "boolean"}}.deep_merge(options)

    wrapper(field_attributes(name, field, options)) do
      wrapper(class: "value") do
        check_box(name, attributes) << releaf_label(name, label, options.deep_merge(label: {minimal: true}))
      end
    end
  end

  def date_or_time_fields(name, type, input: {}, label: {}, field: {}, options: {})
    input = date_or_time_fields_input_attributes(name, type, input)
    options = {field: {type: type.to_s}}.deep_merge(options)
    releaf_text_field(name, input: input, label: label, field: field, options: options)
  end

  def date_or_time_fields_input_attributes(name, type, attributes)
    value = object.send(name)
    {
      class: "#{type}-picker",
      data: {
        "date-format" => date_format_for_jquery,
        "time-format" => time_format_for_jquery
      },
      value: (format_date_or_time_value(value, type) if value)
    }.merge(attributes)
  end

  def normalize_date_or_time_value(value, type)
    case type
    when :date
      value.to_date
    when :datetime
      value.to_datetime
    when :time
      value.to_time
    end
  end

  def format_date_or_time_value(value, type)
    default_format = date_or_time_default_format(type)
    value = normalize_date_or_time_value(value, type)

    if type == :time
      value.strftime(default_format)
    else
      I18n.l(value, default: default_format)
    end
  end

  def time_format_for_jquery
    format = date_or_time_default_format(:time)
    jquery_date_format(format)
  end

  def date_format_for_jquery
    format = date_or_time_default_format(:date)
    jquery_date_format(t("default", scope: "date.formats", default: format))
  end

  def date_or_time_default_format(type)
    case type
    when :date
      "%Y-%m-%d"
    when :datetime
      "%Y-%m-%d %H:%M"
    when :time
      "%H:%M"
    end
  end

  def releaf_datetime_field(name, input: {}, label: {}, field: {}, options: {})
    date_or_time_fields(name, :datetime, input: input, label: label, field: field, options: options)
  end

  def releaf_time_field(name, input: {}, label: {}, field: {}, options: {})
    date_or_time_fields(name, :time, input: input, label: label, field: field, options: options)
  end

  def releaf_date_field(name, input: {}, label: {}, field: {}, options: {})
    date_or_time_fields(name, :date, input: input, label: label, field: field, options: options)
  end

  def releaf_richtext_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    attributes = {
      rows: 5,
      cols: 50,
      class: "richtext",
      value: object.send(name),
      data: {
        "attachment-upload-url" => (controller.respond_to?(:attachment_upload_url) ? controller.attachment_upload_url : '')
      },
    }.merge(input)

    attributes = input_attributes(name, attributes, options)

    options = {field: {type: "richtext"}, label: {translation_key: name.to_s.sub(/_html$/, '').to_s }}.deep_merge(options)
    content = text_area(name, attributes)

    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  def releaf_textarea_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    attributes = {
      rows: 5,
      cols: 75,
      value: object.send(name)
    }.merge(input)

    attributes = input_attributes(name, attributes, options)

    options = {field: {type: "textarea"}}.deep_merge(options)
    content = text_area(name, attributes)

    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  def releaf_email_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    options = {field: {type: "email"}}.deep_merge(options)
    input = {type: "email"}.deep_merge(input)
    releaf_text_field(name, input: input, label: label, field: field, options: options, &block)
  end

  def releaf_link_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    options = {field: {type: "link"}}.deep_merge(options)
    releaf_text_field(name, input: input, label: label, field: field, options: options, &block)
  end

  def releaf_password_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    attributes = input_attributes(name, {autocomplete: "off"}.merge(input), options)
    options = {field: {type: "password"}}.deep_merge(options)
    content = password_field(name, attributes)

    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  def releaf_text_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    attributes = input_attributes(name, {value: object.send(name)}.merge(input), options)
    options = {field: {type: "text"}}.deep_merge(options)
    content = text_field(name, attributes)

    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  def releaf_checkbox_group(name, input: {}, label: {}, field: {}, options: {}, &block)
    options = {field: {type: "boolean-group"}}.deep_merge(options)
    content = releaf_checkbox_group_content(name, options[:items], input: input, options: options)
    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  def releaf_checkbox_group_content(name, items, input: {}, options: {})
    safe_join do
      items.collect do|item|
        releaf_checkbox_group_item(name, item, input: input, options: options)
      end
    end
  end

  def releaf_checkbox_group_item(name, item, input: {}, options: {})
    attributes = releaf_checkbox_group_item_attributes(name, item, input: input, options: options)
    wrapper(class: "type-boolean-group-item") do
      check_box(name, attributes, item[:value], nil) << label(name, item[:label], value: item[:value])
    end
  end

  def releaf_checkbox_group_item_attributes(name, item, input: {}, options: {})
    input_attributes(name, input, options).reject do |attribute, _value|
      %w[id name value type multiple].include?(attribute.to_s)
    end.merge(multiple: true)
  end

  def releaf_text_i18n_field(name, input: {}, label: {}, field: {}, options: {})
    options = {field: {type: "text"}}.deep_merge(options)
    localized_field(name, :text_field, input: input, label: label, field: field, options: options)
  end

  def releaf_link_i18n_field(name, input: {}, label: {}, field: {}, options: {})
    options = {field: {type: "link"}}.deep_merge(options)
    localized_field(name, :text_field, input: input, label: label, field: field, options: options)
  end

  def releaf_richtext_i18n_field(name, input: {}, label: {}, field: {}, options: {})
    input = {
      rows: 5,
      cols: 50,
      class: "richtext",
      data: {
        "attachment-upload-url" => (controller.respond_to?(:attachment_upload_url) ? attachment_upload_url : '')
      },
    }.merge(input)

    options = {field: {type: "richtext"}, label: {translation_key: name.to_s.sub(/_html$/, '').to_s }}.deep_merge(options)
    localized_field(name, :text_area, input: input, label: label, field: field, options: options)
  end

  def releaf_textarea_i18n_field(name, input: {}, label: {}, field: {}, options: {})
    input = {
      rows: 5,
      cols: 75,
    }.merge(input)
    options = {field: {type: "textarea"}}.deep_merge(options)
    localized_field(name, :text_area, input: input, label: label, field: field, options: options)
  end

  def localized_field(name, field_type, input: {}, label: {}, field: {}, options: {})
    options = {i18n: true, label: {translation_key: name}}.deep_merge(options)

    default_locale = cookies[:'releaf.i18n.locale']
    default_locale = default_locale.to_sym unless default_locale.nil?
    default_locale = object.class.globalize_locales.first unless object.class.globalize_locales.include? default_locale

    wrapper(field_attributes(name, field, options)) do
      content = object.class.globalize_locales.collect do |locale|
        localized_name = "#{name}_#{locale}"
        is_default_locale = locale == default_locale
        html_class = ["localization"]
        html_class << "active" if is_default_locale

        tag(:div, class: html_class, data: {locale: locale}) do
          releaf_label(localized_name, label, options) <<
          tag(:div, class: "value") do
            attributes = input_attributes(name, {value: object.send(localized_name)}.merge(input), options)
            send(field_type, localized_name, attributes)
          end
        end
      end

      content.push localization_switch(default_locale)
    end
  end

  def localization_switch(default_locale)
    tag(:div, class: "localization-switch") do
      button_tag(type: 'button', title: t('Switch locale'), class: "trigger") do
        tag(:span, default_locale, class: "label") + tag(:i, nil, class: ["fa", "fa-chevron-down"])
      end <<
      tag(:menu, class: ["block", "localization-menu-items"], type: 'toolbar') do
        tag(:ul, class: "block") do
          object.class.globalize_locales.collect do |locale, i|
            tag(:li) do
              tag(:button, locale, type: "button", data: {locale: locale})
            end
          end
        end
      end
    end
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

    merge_attributes({class: classes, data: {name: name}}, attributes)
  end

  def label_attributes(name, attributes, options)
    attributes
  end

  def input_attributes(name, attributes, options)
    attributes
  end


  def releaf_label(name, attributes, options = {})
    label_options = options.fetch(:label, {})
    attributes = label_attributes(name, attributes, options)
    text = label_text(name, label_options)

    content = label(name, text, attributes)

    if label_options.fetch(:minimal, false) == true
      content
    else
      content += wrapper(label_options[:description], class: "description") if label_options.fetch(:description, nil).present?
      wrapper(content, class: "label-wrap")
    end
  end

  def label_text(name, options = {})
    if options[:label_text].present?
      options[:label_text]
    else
      if options[:translation_key].present?
        key = options[:translation_key]
      else
        key = name.to_s.sub(/_uid$/, '')
      end

      t(key, scope: "activerecord.attributes.#{object.class.name.underscore}")
    end
  end

  def sortable_column_name
    'item_position'
  end

end
