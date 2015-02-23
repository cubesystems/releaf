class Releaf::Builders::Page::LayoutBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::Template

  def output(&block)
    doctype.html_safe << tag(:html) do
      head << body{ yield }
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
      body_content{ yield } << assets(:javascripts, :javascript_include_tag)
    end
  end

  def body_content(&block)
    if access_control.authorized?
      header << menu << tag(:main, id: "main"){ yield } << notifications
    else
      yield
    end
  end

  def notifications
    tag(:div, nil, class: "notifications", 'data-close-text' => t(:close, scope: "admin.global"))
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
    [title, meta, assets(:stylesheets, :stylesheet_link_tag), csrf]
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
    tag(:meta, nil, content: "text/html; charset=utf-8", "http-equiv" => "Content-Type")
  end

  def title
    tag(:title) do
      controller.page_title
    end
  end
end
