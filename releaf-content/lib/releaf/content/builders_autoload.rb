root_path = File.expand_path('../..', File.dirname(__dir__))
files = %w(
  builders/tree
  builders/dialog
  builders/action_dialog
  content_type_dialog_builder
  copy_dialog_builder
  copy_dialog_builder
  go_to_dialog_builder
  move_dialog_builder
  nodes/content_form_builder
  nodes/form_builder
  nodes/index_builder
  nodes/toolbox_builder
)
files.each do|file|
 require "#{root_path}/app/builders/releaf/content/#{file}"
end
