class Releaf::Builders::EditBuilder
  include Releaf::Builders::ResourceView

  attr_accessor :form

  def section_content
    form_for(resource, form_options) do |form|
      self.form = form
      safe_join do
        [index_url_preserver] + section_blocks
      end
    end
  end

  def index_url_preserver
    hidden_field_tag 'index_url', params[:index_url] if params[:index_url].present?
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

  def error_notices
    return unless resource.errors.any?
    tag(:div, id: "error_explanation") do
      error_notices_header <<
      tag(:ul) do
        resource.errors.full_messages.collect do|message|
          tag(:li, message)
        end
      end
    end
  end

  def error_notices_header
    tag(:strong, "#{resource.errors.count} validation #{"error".pluralize(resource.errors.count)} occured:")
  end

  def footer_primary_tools
    [save_button]
  end

  def save_button
    button(t("Save"), "check", class: "primary", data: { type: 'ok', disable: true }, type: "submit")
  end
end
