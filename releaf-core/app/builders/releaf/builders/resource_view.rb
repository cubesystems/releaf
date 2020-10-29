module Releaf::Builders::ResourceView
  include Releaf::Builders::View
  include Releaf::Builders::Resource
  include Releaf::Builders::Toolbox

  def section
    tag(:section, section_attributes) do
      section_content
    end
  end

  def section_content
    section_blocks
  end

  def section_header_text
    resource.new_record? ? t("Create new resource") : resource_title(resource)
  end

  def section_header_extras
    return unless feature_available? :toolbox
    tag(:div, class: "extras toolbox-wrap") do
      toolbox(resource, index_path: index_path)
    end
  end

  def section_body
    tag(:div, section_body_attributes) do
      section_body_blocks
    end
  end

  def section_body_attributes
    {class: ["body"]}
  end

  def section_body_blocks
    []
  end

  def footer_secondary_tools
    list = []
    list << back_to_list_button if back_to_list?
    list
  end

  def back_to_list?
    feature_available?(:index) && params[:index_path].present?
  end

  def back_to_list_button
    button(t("Back to list"), "caret-left", class: "secondary", href: index_path)
  end
end
