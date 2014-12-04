class Releaf::EditBuilder
  include Releaf::ViewBuilder
  attr_accessor :resource, :form

  def initialize(template)
    super
    self.resource = template.instance_variable_get("@resource")
  end

  def section
    template.form_for(resource, template.form_options(template.action_name, resource, :resource)) do |form|
      self.form = form
      safe_join do
        [index_url_preserver] + section_blocks
      end
    end
  end

  def section_header_text
    resource.new_record? ? t('Create new resource', scope: 'admin.global') : template.resource_to_text(resource)
  end

  def section_header_extras
    return unless feature_available? :toolbox
    tag(:div, class: "toolbox-wrap") do
      template.toolbox(resource, index_url: template.index_url)
    end
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
    button(t('Back to list', scope: "admin.global"), "caret-left", class: "secondary", href: template.index_url)
  end

  def section_body
    #- if has_template? "_edit.body_top"
      #= render 'edit.body_top', f: f
    tag(:div, class: "body") do
      [error_notices, form.releaf_fields(form.field_names)]
    end
    #- if has_template? "_edit.body_bottom"
      #= render 'edit.body_bottom', f: f
  end

  def index_url_preserver
    template.hidden_field_tag 'index_url', template.params[:index_url] if template.params[:index_url].present?
  end
end
