root_path = File.expand_path('../..', File.dirname(__dir__))
files = %w(
  builders/tags/releaf_checkbox_group_field
  builders
  builders/base
  builders/template
  builders/view
  builders/collection
  builders/resource
  builders/dialog
  builders/resource_dialog
  builders/confirm_dialog_builder
  builders/confirm_destroy_dialog_builder
  builders/edit_builder
  builders/form_builder
  builders/index_builder
  builders/refused_destroy_dialog_builder
  builders/toolbox
  builders/resource_toolbox
  builders/table_builder
  builders/toolbox_builder
  core/settings/form_builder
  core/settings/table_builder
)
files.each do|file|
 require "#{root_path}/app/helpers/releaf/#{file}"
end
