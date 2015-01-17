class Releaf::Builders::Page::LayoutBuilder
  include Releaf::Builders::Base
  include Releaf::Builders::Template

  def output(&block)
    head << body{ yield }
  end

  def head
    tag(:head) do
      head_blocks
    end
  end

  def body(&block)
    tag(:body, class: body_classes) do
      body_content{ yield } << javascripts_block
    end
  end

  def body_content(&block)
    if controller.permissions_manager.authorized?
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

  def javascripts_block
    safe_join do
      javascripts.collect do |javascript|
        template.javascript_include_tag javascript
      end
    end
  end

  def body_classes
    list = []
    list << "application-#{Rails.application.class.parent_name.downcase}"
    list << "controller-#{params[:controller].tr( '_/', '-' )}"
    list << "view-#{controller.active_view}"  if controller.respond_to? :active_view
    list << "side-compact" if layout_settings("releaf.side.compact")
    list
  end

  def head_blocks
    [title, meta, stylesheets_block, csrf]
  end

  def controller_name
    params[:controller]
  end

  def stylesheets_block
    safe_join do
      stylesheets.collect do |stylesheet|
        template.stylesheet_link_tag(stylesheet, media: 'all')
      end
    end
  end

  def stylesheets
    list = ["releaf/application"]
    if Releaf::AssetsResolver.stylesheet_exists? controller_name
      list << "releaf/controllers/#{controller_name}"
    end

    %w[css.scss.erb scss.erb css.scss scss css.erb css sass.erb sass].each do |ext|
      if File.exists?(Rails.root.to_s + "/app/assets/stylesheets/controllers/#{controller_name}.#{ext}")
         list << "controllers/#{controller_name}"
      end
      if File.exists?(Rails.root.to_s + "/app/assets/stylesheets/releaf/#{Rails.application.class.parent_name.downcase}.#{ext}")
         list << "releaf/#{Rails.application.class.parent_name.downcase}"
      end
    end

    list
  end

  def javascripts
    list = ["releaf/application"]
    list << "releaf/controllers/#{controller_name}" if Releaf::AssetsResolver.javascript_exists? controller_name
    %w[js js.erb].each do |ext|
      if File.exists?(Rails.root.to_s + "/app/assets/javascripts/controllers/#{controller_name}.#{ext}")
        list << "controllers/#{controller_name}"
      end
      if File.exists?(Rails.root.to_s + "/app/assets/javascripts/releaf/#{Rails.application.class.parent_name.downcase}.#{ext}")
        list << "releaf/#{Rails.application.class.parent_name.downcase}"
      end
    end

    list
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
