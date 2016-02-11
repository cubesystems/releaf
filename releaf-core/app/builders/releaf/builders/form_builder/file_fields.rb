module Releaf::Builders::FormBuilder::FileFields
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
end
