class Releaf::FormBuilder < ActionView::Helpers::FormBuilder
  include Releaf::Builder

  def field_names
    resource_class_attributes(object.class)
  end

  def field_render_method_name(name)
    parts = [name]

    builder = self
    until builder.options[:parent_builder].nil? do
      parts << builder.options[:relation_name]
      builder = builder.options[:parent_builder]
    end

    parts << "render"
    parts.reverse.join("_")
  end

  def normalize_fields(fields)
    fields.flatten.map do |item|
      if item.is_a? Hash
        field = item.keys.first
        subfields = item.values.first
      else
        field = item
        subfields = nil
      end

      {
        render_method: field_render_method_name(field),
        field: field,
        association: object.class.reflections.key?(field.to_sym),
        subfields: subfields
      }
    end
  end

  def releaf_fields(*fields)
    safe_join do
      normalize_fields(fields).collect do |item|
        if respond_to? item[:render_method]
          send(item[:render_method])
        elsif item[:association]
          releaf_association_fields(item[:field], item[:subfields])
        else
          releaf_field(item[:field])
        end
      end
    end
  end

  def reflection(reflection_name)
    object.class.reflections[reflection_name.to_sym]
  end

  def association_fields(association_name)
    resource_class_attributes(reflection[association_name].klass) - [reflection(reflection.association_name).foreign_key]
  end

  def releaf_association_fields(association_name, fields)
    fields = association_fields(field) if fields.nil?

    case reflection(association_name).macro
    when :has_many
      releaf_has_many_association(association_name, fields)
    when :belongs_to
      releaf_belongs_to_association(association_name, fields)
    else
      raise 'not implemented'
    end
  end

  def releaf_belongs_to_association(association_name, fields)
    wrapper(class: "nested-wrap", data: { name: association_name}) do
      tag(:div, I18n.t(association_name, scope: template.controller_scope_name), class: "nested-title") <<
      wrapper(class: "item") do
        fields_for(association_name, object.send(association_name)) do |builder|
          builder.releaf_fields_or_field(association_name, fields)
        end
      end
    end
  end

  def releaf_has_many_association(association_name, fields)
    reflection = reflection(association_name)
   sortable_objects = reflection.klass.column_names.include?(sortable_column_name)

    item_template = releaf_has_many_association_fields(association_name, obj: reflection.klass.new, child_index: '_template_', allow_destroy: true,
                                             sortable_objects: sortable_objects, subfields: fields)
    item_template = @template.html_escape(item_template.to_str) # make html unsafe and escape afterwards

    wrapper(class: "nested-wrap", data: { name: association_name, "releaf-template" => item_template}) do
      tag(:h3, I18n.t(association_name, scope: template.controller_scope_name), class: "subheader nested-title") <<
      wrapper(class: "list", data: {sortable: sortable_objects ? '' : nil}) do
        allow_destroy = reflection.active_record.nested_attributes_options.fetch(reflection.name, {}).fetch(:allow_destroy, false)

        safe_join do
          object.send(association_name).each_with_index.map do |obj, i|
            releaf_has_many_association_fields(association_name, obj: obj, child_index: i, allow_destroy: allow_destroy,
                                              sortable_objects: sortable_objects, subfields: fields)
          end
        end

      end << field_type_add_nested
    end
  end

  def releaf_has_many_association_fields(field, obj: nil, subfields: subfields, child_index: nil, allow_destroy: nil, sortable_objects: nil)
    wrapper(class: ["item", "clearInside"], data: {name: field, index: child_index}) do
      fields_for(field, obj, relation_name: field, child_index: child_index, builder: self.class) do |builder|
        builder.releaf_has_many_association_field(field, sortable_objects, subfields, allow_destroy)
      end
    end
  end

  def releaf_has_many_association_field(field, sortable_objects, subfields, allow_destroy)
    content = ActiveSupport::SafeBuffer.new

    if sortable_objects
      content << hidden_field(sortable_column_name.to_sym, class: "item_position")
      content << tag(:div, "&nbsp;".html_safe, class: "handle")
    end

    content << releaf_fields(subfields)
    content << field_type_remove_nested if allow_destroy

    content
  end

  def field_type_remove_nested
    button_attributes = {title: I18n.t('Remove item', scope: 'admin.global'), class: "danger only-icon remove-nested-item"}
    wrapper(class: "remove-item-box") do
      template.releaf_button(nil, "trash-o lg", button_attributes) << hidden_field("_destroy", class: "destroy")
    end
  end

  def field_type_add_nested
    template.releaf_button(I18n.t('Add item', scope: 'admin.global'), "plus", class: "primary add-nested-item")
  end

  def field_type_method(name)
    type = Releaf::TemplateFieldTypeMapper.field_type_name(object, name)
    localization = Releaf::TemplateFieldTypeMapper.use_i18n?(object, name)

    "releaf_#{type}_#{'i18n_' if localization}field"
  end

  def releaf_field(name, input: {}, label: {}, field: {}, options: {})
    method_name = field_type_method(name)
    send(method_name, name, input: input, label: label, field: field, options: options)
  end

  def releaf_item_field(name, input: {}, label: {}, field: {}, options: {})
    label = {translation_key: name.to_s.sub(/_id$/, '').to_s}.deep_merge(label)
    attributes = input_attributes(name, {value: object.send(name)}.merge(input), options)
    options = {field: {type: "item"}}.deep_merge(options)

    relation_name = name.to_s.sub(/_id$/, '').to_sym

    if options.key? :select_options
      if options[:select_options].is_a? Array
        choices = template.options_for_select(options[:select_options], object.send(name))
      else
        choices = options[:select_options]
      end
    else
      collection = object.class.reflect_on_association(relation_name).try(:klass).try(:all)
      choices = template.options_from_collection_for_select(collection, :id,
                                                   controller.resource_to_text_method(collection.first), object.send(name))
    end

    # add empty value when validation exists, so user is forced to choose something
    unless options.key? :include_blank
      options[:include_blank] = true
      object.class.validators_on(name).each do |validator|
        next unless validator.is_a? ActiveModel::Validations::PresenceValidator
        # if new record, or object is missing (was deleted)
        options[:include_blank] = object.new_record? || object.send(relation_name).blank?
        break
      end
    end


    content = select(name, choices, options, attributes)
    input_wrapper_with_label(name, content, label: label, field: field, options: options)
  end

  def releaf_image_field(name, input: {}, label: {}, field: {}, options: {})
    name = name.to_s.sub(/_uid$/, '')

    attributes = {
      accept: 'image/png,image/jpeg,image/bmp,image/gif'
    }.merge(input)

    attributes = input_attributes(name, attributes, options)

    options = {field: {type: "image"}}.deep_merge(options)
    content = file_field(name, attributes)
    unless object.send(name).blank?
      content += tag(:div, class: "value_preview") do
        inner_content = tag(:div, class: "image_wrap") do
          thumbnail = template.image_tag(object.send(name).thumb('410x128>').url, alt: '')
          hidden_field("retained_#{name}") +
            template.link_to(thumbnail, object.send(name).url, target: :_blank, class: :ajaxbox, rel: :image)
        end
        inner_content << releaf_file_remove_button(name)
      end
    end

    input_wrapper_with_label(name, content, label: label, field: field, options: options)
  end

  def releaf_file_remove_button(name)
    tag(:div, class: "remove") do
      check_box("remove_#{name}") << label("remove_#{name}", I18n.t("Remove", scope: 'admin.global'))
    end
  end

  def releaf_file_field(name, input: {}, label: {}, field: {}, options: {})
    name = name.to_s.sub(/_uid$/, '')
    attributes = input_attributes(name, input, options)
    options = {field: {type: "file"}}.deep_merge(options)

    content = file_field(name, attributes)
    unless object.send(name).blank?
      content << hidden_field("retained_#{name}")
      content << template.link_to(I18n.t("Download"), object.send(name).url, target: "_blank")
      content << releaf_file_remove_button(name)
    end

    input_wrapper_with_label(name, content, label: label, field: field, options: options)
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

  def releaf_datetime_field(name, input: {}, label: {}, field: {}, options: {})
    input = {
      class: 'datetime_picker',
      data: {
        date_format: template.jquery_date_format(I18n.t("date.formats.default", default: "%Y-%m-%d"))
      },
      value: (I18n.l(object.send(name), default: "%Y-%m-%d %H:%M") if object.send(name))
    }.merge(input)

    options = {field: {type: "datetime"}}.deep_merge(options)

    releaf_text_field(name, input: input, label: label, field: field, options: options)
  end

  def releaf_time_field(name, input: {}, label: {}, field: {}, options: {})
    input = {
      class: 'time_picker',
      format: 'HH:mm',
      data: {
        date_format: template.jquery_date_format(I18n.t("date.formats.default", default: "%Y-%m-%d"))
      },
      value: object.send(name).try(:strftime, '%H:%M')
    }.merge(input)

    options = {
      field: {type: "time"},
      label: {
        description: I18n.t("field.Format %{_format}", default: 'Format %{_format}',
                            _format: I18n.t("format.input.time", default: 'hh:mm'))

      }
    }.deep_merge(options)

    releaf_text_field(name, input: input, label: label, field: field, options: options)
  end


  def releaf_date_field(name, input: {}, label: {}, field: {}, options: {})
    input = {
      class: 'date_picker',
      data: {
        date_format: template.jquery_date_format(I18n.t("date.formats.default", default: "%Y-%m-%d"))
      },
      value: (I18n.l(object.send(name), default: "%Y-%m-%d") if object.send(name))
    }.deep_merge(input)
    options = {field: {type: "date"}}.deep_merge(options)

    releaf_text_field(name, input: input, label: label, field: field, options: options)
  end

  def releaf_richtext_field(name, input: {}, label: {}, field: {}, options: {})
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

    input_wrapper_with_label(name, content, label: label, field: field, options: options)
  end

  def releaf_textarea_field(name, input: {}, label: {}, field: {}, options: {})
    attributes = {
      rows: 5,
      cols: 75,
      value: object.send(name)
    }.merge(input)

    attributes = input_attributes(name, attributes, options)

    options = {field: {type: "textarea"}}.deep_merge(options)
    content = text_area(name, attributes)

    input_wrapper_with_label(name, content, label: label, field: field, options: options)
  end

  def releaf_email_field(name, input: {}, label: {}, field: {}, options: {})
    options = {field: {type: "email"}}.deep_merge(options)
    input = {type: "email"}.deep_merge(input)
    releaf_text_field(name, input: input, label: label, field: field, options: options)
  end

  def releaf_link_field(name, input: {}, label: {}, field: {}, options: {})
    options = {field: {type: "link"}}.deep_merge(options)
    releaf_text_field(name, input: input, label: label, field: field, options: options)
  end

  def releaf_password_field(name, input: {}, label: {}, field: {}, options: {})
    attributes = input_attributes(name, {autocomplete: "off"}.merge(input), options)
    options = {field: {type: "password"}}.deep_merge(options)
    content = password_field(name, attributes)

    input_wrapper_with_label(name, content, label: label, field: field, options: options)
  end

  def releaf_text_field(name, input: {}, label: {}, field: {}, options: {})
    attributes = input_attributes(name, {value: object.send(name)}.merge(input), options)
    options = {field: {type: "text"}}.deep_merge(options)
    content = text_field(name, attributes)

    input_wrapper_with_label(name, content, label: label, field: field, options: options)
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

    default_locale = template.cookies[:'releaf.i18n.locale']
    default_locale = default_locale.to_sym unless default_locale.nil?
    default_locale = object.class.globalize_locales.first unless object.class.globalize_locales.include? default_locale

    wrapper(field_attributes(name, field, options)) do
      content = safe_join do
        object.class.globalize_locales.collect do |locale|
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
      end

      content += localization_switch(default_locale)
    end
  end

  def localization_switch(default_locale)
    tag(:div, class: "localization-switch") do
      template.button_tag(type: 'button', title: I18n.t('Switch locale', scope: 'admin.global'), class: "trigger") do
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
      releaf_label(name, label, options) + wrapper(input_content, class: "value")
    end
  end

  def field(name, attributes, options, &block)
    tag(:div, field_attributes(name, attributes, options), nil, nil, &block)
  end

  def field_attributes(name, attributes, options)
    type = options.fetch(:field, {}).fetch(:type, nil)

    classes = ["field", "type_#{type}"]
    classes << "i18n" if options.key? :i18n

    template.merge_attributes({class: classes, data: {name: name}}, attributes)
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
      content += wrapper(label_options[:description], class: "description") unless label_options.fetch(:description, nil).blank?
      wrapper(content, class: "label_wrap") #TODO: label_wrap > label
    end
  end

  def wrapper(content_or_attributes_with_block, attributes = {}, &block)
    if block_given?
      tag(:div, content_or_attributes_with_block, nil, nil, &block)
    else
      tag(:div, content_or_attributes_with_block, attributes)
    end
  end

  def label_text(name, options = {})
    unless options[:label_text].blank?
      options[:label_text]
    else
      unless options[:translation_key].blank?
        key = options[:translation_key]
      else
        key = name.to_s.sub(/_uid$/, '')
      end

      I18n.t(key, scope: "activerecord.attributes.#{object.class.name.underscore}")
    end
  end

  def sortable_column_name
    'item_position'
  end

  # shortcut helper methods
  def template
    @template
  end
end
