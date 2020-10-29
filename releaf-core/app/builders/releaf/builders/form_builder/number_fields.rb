module Releaf::Builders::FormBuilder::NumberFields
  def releaf_number_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    attributes = input_attributes(name, {value: object.send(name), step: "any", class: "text" }.merge(input), options)
    options = {field: {type: "number"}}.deep_merge(options)
    content = number_field(name, attributes)

    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  alias_method :releaf_integer_field, :releaf_number_field
  alias_method :releaf_float_field, :releaf_number_field
  alias_method :releaf_decimal_field, :releaf_number_field
end
