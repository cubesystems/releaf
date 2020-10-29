class Releaf::Builders::EditBuilder
  include Releaf::Builders::ResourceView

  attr_accessor :form

  def section_content
    form_for(resource, form_options) do |form|
      self.form = form
      safe_join do
        [index_path_preserver] + section_blocks
      end
    end
  end

  def index_path_preserver
    hidden_field_tag "index_path", params[:index_path] if params[:index_path].present?
  end

  def section_body_blocks
    [error_notices, form_fields]
  end

  def form_fields
    form.releaf_fields(form.field_names.to_a)
  end

  def form_url
    url_for(action: form_action, id: resource.id)
  end

  def form_action
    resource.new_record? ? 'create' : 'update'
  end

  def resource_name
    :resource
  end

  def form_builder_class
    builder_class(:form)
  end

  def form_options
    {
      builder: form_builder_class,
      as: resource_name,
      url: form_url,
      html: form_attributes
    }
  end

  def form_identifier
    action = !resource.respond_to?(:persisted?) || resource.persisted? ? :edit : :new
    "#{action}-#{resource_name}"
  end

  def form_classes
    classes = [ form_identifier ]
    classes << "has-error" if resource.errors.any?
    classes
  end

  def form_attributes
    {
      multipart: true,
      id: form_identifier,
      class: form_classes,
      data: {
        "remote" => true,
        "remote-validation" => true,
        "type" => :json,
      },
      novalidate: ""
    }
  end

  def error_notices
    return unless resource.errors.any?
    tag(:div, class: "form-error-box") do
      error_notices_header <<
      tag(:ul) do
        resource.errors.full_messages.collect do|message|
          tag(:li, message, class: "error")
        end
      end
    end
  end

  def error_notices_header
    tag(:strong, "#{resource.errors.count} validation #{"error".pluralize(resource.errors.count)} occured:")
  end

  def footer_primary_tools
    tools = []
    tools << save_and_create_another_button if create_another_available?
    tools << save_button
    tools
  end

  def create_another_available?
    resource.present? && resource.new_record? && feature_available?(:create_another)
  end

  def save_and_create_another_button
    button(t("Save and create another"), "plus", name: "after_save", value: "create_another", class: "secondary", data: { type: 'ok', disable: true }, type: "submit")
  end

  def save_button
    button(t("Save"), "check", class: "primary", data: { type: 'ok', disable: true }, type: "submit")
  end
end
