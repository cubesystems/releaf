module Releaf::Tags
  module CheckboxGroupField
    def releaf_checkbox_group_field(name, input: {}, label: {}, field: {}, options: {}, &block)
      options = {field: {type: "boolean-group"}}.deep_merge(options)
      content = releaf_checkbox_group_content(name, input: input, options: options)
      input_wrapper_with_label(name, content, label: label, field: field, options: options, &block)
    end

    def releaf_checkbox_group_content(name, input: {}, options: {})
      association_options = options[:association]
      association = object.send(name)
      key_field = association_options[:field]

      safe_join do
        association_options[:values].collect do|value|
          item = association.find_by(key_field => value) || association.build(key_field => value)

          fields_for(name, item, relation_name: name, builder: self.class) do |builder|
            builder.releaf_checkbox_group_item(association_options)
          end
        end
      end
    end

    def releaf_checkbox_group_item(association_options)
      label_text = t(object.send(association_options[:field]), scope: association_options[:translation_scope])
      wrapper(class: "type-boolean-group-item") do
        [hidden_field(:_destroy, value: object.new_record?, class: "destroy"),
         check_box(association_options[:field], {class: "keep", name: "keep"}, (object.send(association_options[:field]) if object.persisted?)),
         label(association_options[:field], label_text),
         hidden_field(association_options[:field])
        ]
      end
    end
  end
end
