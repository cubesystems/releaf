class Releaf::Builders::EditBuilder
  include Releaf::Builders::View
  include Releaf::Builders::Resource

  attr_accessor :form

  def section
    tag(:section) do
      template.form_for(resource, template.form_options(template.action_name, resource, :resource)) do |form|
        self.form = form
        safe_join do
          [index_url_preserver] + section_blocks
        end
      end
    end
  end

  def index_url_preserver
    template.hidden_field_tag 'index_url', template.params[:index_url] if template.params[:index_url].present?
  end

  def section_header_text
    resource.new_record? ? t('Create new resource', scope: 'admin.global') : template.resource_to_text(resource)
  end

  def section_header_extras
    return unless feature_available? :toolbox
    tag(:div, class: "toolbox-wrap") do
      template.toolbox(resource, index_url: index_url)
    end
  end


  def section_body
    tag(:div, class: "body") do
      section_body_blocks
    end
  end

  def section_body_blocks
    [error_notices, form_fields]
  end

  def form_fields
    form.releaf_fields(form.field_names)
  end

  #-#TODO: improve style/html
  def error_notices
    return unless form.object.errors.any?
    tag(:div, id: "error_explanation") do
      tag(:strong, "#{pluralize(f.object.errors.count, "error")} prohibited this news from being saved:") <<
      tag(:ul) do
        form.object.errors.full_messages.collect do|message|
          tag(:li, message)
        end
      end
    end
  end

  def footer_primary_tools
    [save_button]
  end

  def save_button
    button(t('Save', scope: "admin.global"), "check", class: "primary", data: { type: 'ok' }, type: "submit")
  end

  def footer_secondary_tools
    list = []
    list << back_to_list_button if back_to_list?
    list
  end

  def back_to_list?
    feature_available?(:index) && template.params[:index_url].present?
  end

  def back_to_list_button
    button(t('Back to list', scope: "admin.global"), "caret-left", class: "secondary", href: index_url)
  end

end
