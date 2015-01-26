root_path = File.expand_path('../..', File.dirname(__dir__))
files = %w(
  roles/form_builder
  roles/table_builder
  users/form_builder
  users/table_builder
  profile/form_builder
)
files.each do|file|
 require "#{root_path}/app/helpers/releaf/permissions/#{file}"
end
