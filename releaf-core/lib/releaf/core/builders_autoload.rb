root_path = File.expand_path('../..', File.dirname(__dir__))
files = %w(
  builders/tags/releaf_associated_set_field
  builders
  builders/base
  builders/orderer
  builders/template
  builders/toolbox
  builders/view
  builders/collection
  builders/resource
  builders/resource_dialog
  builders/resource_view
  builders/confirm_dialog_builder
  builders/confirm_destroy_dialog_builder
  builders/edit_builder
  builders/form_builder
  builders/index_builder
  builders/refused_destroy_dialog_builder
  builders/table_builder
  builders/toolbox_builder
  core/settings/form_builder
  core/settings/table_builder
)
files.each do|file|
 require "#{root_path}/app/builders/releaf/#{file}"
end
