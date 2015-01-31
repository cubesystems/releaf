root_path = File.expand_path('../..', File.dirname(__dir__))
files = %w(
  builders_common
  edit_builder
  table_builder
  index_builder
)
files.each do|file|
 require "#{root_path}/app/helpers/releaf/i18n_database/translations/#{file}"
end
