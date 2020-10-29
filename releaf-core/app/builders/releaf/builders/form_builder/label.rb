module Releaf::Builders::FormBuilder::Label
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

      translate_attribute(key)
    end
  end

  def label_attributes(_name, attributes, _options)
    attributes
  end
end
