module Releaf::Builders::Page
  class LayoutBuilder
    include Releaf::Builders::Base
    include Releaf::Builders::Template

    def output(&block)
      doctype.html_safe << tag(:html) do
        head << body(&block)
      end
    end

    def doctype
      "<!DOCTYPE html>"
    end

    def head
      tag(:head) do
        head_blocks
      end
    end

    def body
      tag(:body, body_atttributes) do
        safe_join{ body_content_blocks{ yield } }
      end
    end

    def body_atttributes
      {class: body_classes, "data-settings-path" => settings_path, "data-layout-features" => features.join(" ")}
    end

    def settings_path
      url_for(action: "store_settings", controller: "/releaf/root", only_path: true)
    end

    def feature_available?(feature)
      features.include? feature
    end

    def body_content_blocks
      parts = []
      parts << header if feature_available?(:header)
      parts << menu if feature_available?(:sidebar)
      parts << tag(:main, id: :main){ yield } if feature_available?(:main)
      parts << notifications
      parts << assets(:javascripts, :javascript_include_tag)
      parts
    end

    def notifications
      tag(:div, nil, class: 'notifications', 'data' => {'close-text' => t("Close")})
    end

    def header
      tag(:header, header_builder.new(template).output)
    end

    def header_builder
      Releaf::Builders::Page::HeaderBuilder
    end

    def menu
      tag(:aside, menu_builder.new(template).output)
    end

    def menu_builder
      Releaf::Builders::Page::MenuBuilder
    end

    def features
      controller.layout_features
    end

    def assets(type, tag_method)
      safe_join do
        send(type).collect do |asset|
          template.send(tag_method, asset)
        end
      end
    end

    def body_classes
      list = []
      list << "application-#{Rails.application.class.parent_name.downcase}"
      list += controller_body_classes
      list << "view-#{controller.active_view}"  if controller.respond_to? :active_view
      list << "side-compact" if layout_settings("releaf.side.compact")
      list
    end

    def controller_classes
      ancestors = controller.class.ancestors.grep(Class)
      slice_index = ancestors.index(Releaf::ActionController) || (ancestors.index(controller.class) + 1)
      ancestors[0, slice_index].reverse
    end

    def controller_body_classes
      controller_classes.collect do|c_class|
        "controller-" + c_class.name.gsub(/Controller$/, "").underscore.tr( '_/', '-' )
      end
    end

    def head_blocks
      [title, content_type, favicons, ms_tile, assets(:stylesheets, :stylesheet_link_tag), csrf]
    end

    def controller_name
      params[:controller]
    end

    def assets_resolver
      Releaf::AssetsResolver
    end

    def stylesheets
      assets_resolver.controller_assets(controller_name, :stylesheets)
    end

    def javascripts
      assets_resolver.controller_assets(controller_name, :javascripts)
    end

    def csrf
      template.csrf_meta_tags
    end

    def content_type
      meta(content: 'text/html; charset=utf-8', 'http-equiv': 'Content-Type')
    end

    def meta(options)
      tag(:meta, nil, options)
    end

    def title
      tag(:title) do
        controller.page_title
      end
    end

    def favicon_path
      File.join('releaf', 'icons')
    end

    def ms_tile_path
      favicon_path
    end

    def ms_tile_color
      '#151515'
    end

    def favicon(source, options = {})
      controller.view_context.favicon_link_tag(File.join(favicon_path, source), options)
    end

    def apple_favicon(source, options = {})
      favicon(source, options.merge(rel: 'apple-touch-icon-precomposed', type: 'image/png'))
    end

    def favicons
      [
        apple_favicon("favicon.png"),
        apple_favicon("apple-touch-icon-152x152-precomposed.png", sizes: "152x152"),
        apple_favicon("apple-touch-icon-114x114-precomposed.png", sizes: "114x114"),
        apple_favicon("apple-touch-icon-72x72-precomposed.png", sizes: "72x72"),
        favicon("favicon.png", type: 'image/png', rel: 'icon'),
      ]
    end

    def ms_tile
      tile_path = ActionController::Base.helpers.image_path(File.join(ms_tile_path, 'msapplication-tile-144x144.png'))
      [
        meta(name: 'msapplication-TileColor', content: ms_tile_color),
        meta(name: 'msapplication-TileImage', content: tile_path)
      ]
    end
  end
end
