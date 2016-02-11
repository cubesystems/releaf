module Releaf::Builders::FormBuilder::RichtextFields
  def releaf_richtext_field(name, input: {}, label: {}, field: {}, options: {}, &block)
    attributes = richtext_input_attributes(name)
      .merge(value: object.send(name))
      .merge(input)
    attributes = input_attributes(name, attributes, options)

    options = richtext_options(name, options)
    content = text_area(name, attributes)

    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  def richtext_input_attributes(_name)
    {
      rows: 5,
      cols: 50,
      class: "richtext",
      data: {
        "attachment-upload-url" => (controller.respond_to?(:releaf_richtext_attachment_upload_url) ? controller.releaf_richtext_attachment_upload_url : '')
      },
    }
  end

  def richtext_options(name, options)
    {field: {type: "richtext"}, label: {translation_key: name.to_s.sub(/_html$/, '').to_s }}.deep_merge(options)
  end
end
