module Releaf::Builders::FormBuilder::AssociatedSetField
  def releaf_associated_set_field(name, label: {}, field: {}, options: {}, &block)
    options = {field: {type: "associated-set"}}.deep_merge(options)
    content = releaf_associated_set_content(name, options: options)
    input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
  end

  def releaf_associated_set_content(name, options: {})
    association_options = options[:association]
    association = object.send(name)
    key_field = association_options[:field]

    list = []

    association_options[:items].each_pair do|value, label_text|
      item = association.find_by(key_field => value) || association.build(key_field => value)

      list << fields_for(name, item, relation_name: name, builder: self.class) do |builder|
        builder.releaf_associated_set_item(association_options, label_text)
      end
    end

    safe_join do
      list
    end
  end

  def releaf_associated_set_item(association_options, label_text)
    wrapper(class: "type-associated-set-item") do
      [hidden_field(:_destroy, value: object.new_record?, class: "destroy"),
       check_box(association_options[:field], {class: "keep", name: "keep"}, (object.send(association_options[:field]) if object.persisted?)),
       label(association_options[:field], label_text),
       hidden_field(association_options[:field])
      ]
    end
  end
end
