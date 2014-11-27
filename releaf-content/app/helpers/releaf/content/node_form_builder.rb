module Releaf::Content
  class NodeFormBuilder < Releaf::FormBuilder
    def render_locale
      releaf_item_field(:locale, options: render_locale_options)
    end

    def render_locale_options
      {
        select_options: I18n.available_locales,
        include_blank: object.locale.blank?
      }
    end

    def render_content_type
      content_type_input_options = {disabled: true, value: I18n.t(object.content_type.underscore, scope: 'admin.content_types')}
      releaf_text_field(:content_type, input: content_type_input_options)
    end

    def render_slug
      input = {
        value: object.slug,
        data: {'generator-url' => template.generate_url_releaf_content_nodes_path(parent_id: object.parent_id, id: object.id)}
      }

      options = {field: {type: "text"}}
      attributes = input_attributes(:slug, input, options)
      content = text_field(:slug, attributes) << slug_button

      field(:slug, {}, options) do
        releaf_label(:slug, {}, options) << wrapper(content, class: "value") << wrapper(slug_link, class: "link")
      end
    end

    def render_item_position
      releaf_item_field(:item_position, options: item_position_options)
    end

    def item_position_options
      {
        include_blank: false,
        select_options: template.options_for_select(item_position_select_options, object.item_position)
      }
    end

    def item_position_select_options
      after_text = I18n.t('After', scope: 'admin.global')
      list = [[I18n.t('First', scope: 'admin.global'), 0]]
      template.controller.instance_variable_get(:@order_nodes).each do |node|
        list.push [after_text + ' ' + node.name, node.lower_item ? node.lower_item.item_position : node.item_position + 1 ]
      end

      list
    end

    def slug_base_url
      "#{template.request.protocol}#{template.request.host_with_port}#{object.parent.try(:url)}/"
    end

    def slug_link
      template.link_to(object.url) do
        safe_join do
          [slug_base_url, tag(:span, object.slug), '/']
        end
      end
    end

    def slug_button
      attributes = {title: I18n.t('Suggest slug', scope: template.controller_scope_name), class: "secondary generate"}
      template.releaf_button(nil, "keyboard-o", attributes)
    end
  end
end
