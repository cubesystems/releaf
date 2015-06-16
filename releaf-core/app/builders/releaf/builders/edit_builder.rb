class Releaf::Builders::EditBuilder
  include Releaf::Builders::View
  include Releaf::Builders::Resource
  include Releaf::Builders::Toolbox

  attr_accessor :form

  def section
    tag(:section, section_attributes) do
      form_for(resource, form_options) do |form|
        self.form = form
        safe_join do
          [index_url_preserver] + section_blocks
        end
      end
    end
  end

  def index_url_preserver
    hidden_field_tag 'index_url', params[:index_url] if params[:index_url].present?
  end

  def section_header_text
    resource.new_record? ? t('Create new resource', scope: 'admin.global') : resource_to_text(resource)
  end

  def section_header_extras
    return unless feature_available? :toolbox
    tag(:div, class: "extras toolbox-wrap") do
      toolbox(resource, index_url: index_url)
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
    [error_notices, form_fields]
  end

  def form_fields
    form.releaf_fields(form.field_names.to_a)
  end

  def form_options
    controller.form_options(action_name, resource, :resource)
  end

  #-#TODO: improve style/html
  def error_notices
    return unless form.object.errors.any?
    tag(:div, id: "error_explanation") do
      error_notices_header <<
      tag(:ul) do
        form.object.errors.full_messages.collect do|message|
          tag(:li, message)
        end
      end
    end
  end

  def error_notices_header
    tag(:strong, "#{form.object.errors.count} validation #{"error".pluralize(form.object.errors.count)} occured:")
  end

  def footer_primary_tools
    [save_button]
  end

  def save_button
    button(t('Save', scope: "admin.global"), "check", class: "primary", data: { type: 'ok', disable: true }, type: "submit")
  end

  def footer_secondary_tools
    list = []
    list << back_to_list_button if back_to_list?
    list
  end

  def back_to_list?
    feature_available?(:index) && params[:index_url].present?
  end

  def back_to_list_button
    button(t('Back to list', scope: "admin.global"), "caret-left", class: "secondary", href: index_url)
  end

end
