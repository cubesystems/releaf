module Releaf::Content
  class NodeFormBuilder < Releaf::Builders::FormBuilder
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
      input = {disabled: true, value: t(object.content_type.underscore, scope: 'admin.content_types')}
      releaf_text_field(:content_type, input: input)
    end

    def render_slug
      url = url_for(controller: "/releaf/content/nodes", action: "generate_url", parent_id: object.parent_id, id: object.id)
      input = {
        data: {'generator-url' => url}
      }

      releaf_field(:slug, input: input) do
        slug_button << wrapper(slug_link, class: "link")
      end
    end

    def render_item_position
      releaf_item_field(:item_position, options: item_position_options)
    end

    def item_position_options
      {
        include_blank: false,
        select_options: options_for_select(item_position_select_options, object.item_position)
      }
    end

    def item_position_select_options
      after_text = t('After', scope: 'admin.global')
      list = [[t('First', scope: 'admin.global'), 0]]
      controller.instance_variable_get(:@order_nodes).each do |node|
        list.push [after_text + ' ' + node.name, node.lower_item ? node.lower_item.item_position : node.item_position + 1 ]
      end

      list
    end

    def slug_base_url
      "#{request.protocol}#{request.host_with_port}#{object.parent.try(:url)}/"
    end

    def slug_link
      link_to(object.url) do
        safe_join do
          [slug_base_url, tag(:span, object.slug), '/']
        end
      end
    end

    def slug_button
      button(nil, "keyboard-o", title: t('Suggest slug'), class: "secondary generate")
    end
  end
end
