module Releaf::Builders::FormBuilder::BooleanFields
  def releaf_boolean_field(name, input: {}, label: {}, field: {}, options: {})
    attributes = input_attributes(name, input, options)
    options = {field: {type: "boolean"}}.deep_merge(options)

    wrapper(field_attributes(name, field, options)) do
      wrapper(class: "value") do
        check_box(name, attributes) << releaf_label(name, label, options.deep_merge(label: {minimal: true}))
      end
    end
  end
end
