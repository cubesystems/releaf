class Releaf::Builders::Page::LayoutBuilder
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

  def body(&block)
    tag(:body, class: body_classes) do
      body_content(&block) << assets(:javascripts, :javascript_include_tag)
    end
  end

  def body_content(&block)
    if access_control.authorized?
      header << menu << tag(:main, id: "main", &block) << notifications
    else
      yield
    end
  end

  def notifications
    tag(:div, nil, class: 'notifications', 'data': {'close-text': t("Close")})
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
    slice_index = ancestors.index(Releaf::BaseController) || (ancestors.index(controller.class) + 1)
    ancestors[0, slice_index].reverse
  end

  def controller_body_classes
    controller_classes.collect do|c_class|
      "controller-" + c_class.name.gsub(/Controller$/, "").underscore.tr( '_/', '-' )
    end
  end

  def head_blocks
    [title, meta, favicon, ms_tile, assets(:stylesheets, :stylesheet_link_tag), csrf]
  end

  def controller_name
    params[:controller]
  end

  def stylesheets
    Releaf.assets_resolver.controller_assets(controller_name, :stylesheets)
  end

  def javascripts
    Releaf.assets_resolver.controller_assets(controller_name, :javascripts)
  end

  def csrf
    template.csrf_meta_tags
  end

  def meta
    tag(:meta, nil, content: 'text/html; charset=utf-8', 'http-equiv': 'Content-Type')
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
    File.join('releaf', 'icons')
  end

  def ms_tile_color
    '#151515'
  end

  def favicon
    context = controller.view_context

    tags = []
    tags << context.favicon_link_tag(
      File.join(favicon_path, 'favicon.png'),
      rel: 'apple-touch-icon-precomposed',
      type: 'image/png'
    )
    tags << context.favicon_link_tag(
      File.join(favicon_path, 'apple-touch-icon-152x152-precomposed.png'),
      rel: 'apple-touch-icon-precomposed',
      type: 'image/png',
      sizes: '152x152'
    )
    tags << context.favicon_link_tag(
      File.join(favicon_path, 'apple-touch-icon-114x114-precomposed.png'),
      rel: 'apple-touch-icon-precomposed',
      type: 'image/png',
      sizes: '114x114'
    )
    tags << context.favicon_link_tag(
      File.join(favicon_path, 'apple-touch-icon-72x72-precomposed.png'),
      rel: 'apple-touch-icon-precomposed',
      type: 'image/png',
      sizes: '72x72'
    )
    tags << context.favicon_link_tag(
      File.join(favicon_path, 'favicon.png'),
      rel: 'icon',
      type: 'image/png'
    )
    tags << (
      '<!--[if IE]>'.html_safe +
      context.favicon_link_tag(File.join(favicon_path, 'favicon.ico')) +
      '<![endif]-->'.html_safe
    )
  end

  def ms_tile
    tags = []
    tags << tag(
      :meta,
      nil,
      name: 'msapplication-TileColor',
      content: ms_tile_color
    )
    tags << tag(
      :meta,
      nil,
      name: 'msapplication-TileImage',
      content: ActionController::Base.helpers.image_path(
        File.join(ms_tile_path, 'msapplication-tile-144x144.png')
      )
    )
  end
end
