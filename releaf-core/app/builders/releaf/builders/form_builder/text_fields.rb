module Releaf::Builders::FormBuilder::TextFields
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
    attributes = input_attributes(name, {autocomplete: "off", class: "text"}.merge(input), options)
    options = {field: {type: "password"}}.deep_merge(options)
    content = password_field(name, attributes)

    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  def releaf_text_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    attributes = input_attributes(name, {value: object.send(name), class: "text"}.merge(input), options)
    options = {field: {type: "text"}}.deep_merge(options)
    content = text_field(name, attributes)

    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end
end
