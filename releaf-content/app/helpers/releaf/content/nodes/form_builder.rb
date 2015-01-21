module Releaf::Content::Nodes
  class FormBuilder < Releaf::Builders::FormBuilder
    def field_names
      %w(node_fields_block content_fields_block)
    end

    def node_fields
      [:parent_id, :name, :content_type, :slug, :item_position, :active, :locale]
    end

    def render_node_fields_block
      tag(:div, class: ["section", "node-fields", "clear-inside"]) do
        releaf_fields(node_fields)
      end
    end

    def render_parent_id
      hidden_field(:parent_id) if object.new_record?
    end

    def content_fields
      object.content_class.releaf_fields_to_display(nil) if object.content_class.respond_to?(:releaf_fields_to_display)
    end

    def render_content_fields_block
      return unless content_fields.present?
      tag(:div, class: ["section", "content-fields"]) do
        fields_for(:content, object.content, builder: content_builder_class) do |form|
          form.releaf_fields(content_fields)
        end
      end
    end

    def content_builder_class
      self.class
    end

    def render_locale
      releaf_item_field(:locale, options: render_locale_options) if object.locale_selection_enabled?
    end

    def render_locale_options
      {
        select_options: I18n.available_locales,
        include_blank: object.locale.blank?
      }
    end

    def render_content_type
      input = {disabled: true, value: t(object.content_type.underscore, scope: 'admin.content_types')}
      releaf_text_field(:content_type, input: input) do
        hidden_field_tag(:content_type, params[:content_type]) if object.new_record?
      end
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
      order_nodes.each do |node|
        list.push [after_text + ' ' + node.name, node.lower_item ? node.lower_item.item_position : node.item_position + 1 ]
      end

      list
    end

    def order_nodes
      object.class.where(parent_id: object.parent_id).where('id <> ?',  object.id.to_i)
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
