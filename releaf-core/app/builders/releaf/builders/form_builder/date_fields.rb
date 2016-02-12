module Releaf::Builders::FormBuilder::DateFields
  def date_or_time_field(name, type, input: {}, label: {}, field: {}, options: {})
    input = date_or_time_field_input_attributes(name, type, input)
    options = {field: {type: type.to_s}}.deep_merge(options)
    releaf_text_field(name, input: input, label: label, field: field, options: options)
  end

  def date_or_time_field_input_attributes(name, type, attributes)
    {
      class: "text #{type}-picker",
      value: Releaf::Builders::Utilities::DateFields.format_date_or_time_value(object.send(name), type),
      data: {
        "date-format" => Releaf::Builders::Utilities::DateFields.date_format_for_jquery,
        "time-format" => Releaf::Builders::Utilities::DateFields.time_format_for_jquery
      }
    }.deep_merge(attributes)
  end

  def releaf_datetime_field(name, input: {}, label: {}, field: {}, options: {})
    date_or_time_field(name, :datetime, input: input, label: label, field: field, options: options)
  end

  def releaf_time_field(name, input: {}, label: {}, field: {}, options: {})
    date_or_time_field(name, :time, input: input, label: label, field: field, options: options)
  end

  def releaf_date_field(name, input: {}, label: {}, field: {}, options: {})
    date_or_time_field(name, :date, input: input, label: label, field: field, options: options)
  end
end
