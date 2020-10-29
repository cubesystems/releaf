# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
[
  Releaf::Permissions::User,
  Releaf::Permissions::Role,
  Releaf::Permissions::Permission,
  Releaf::I18nDatabase::I18nEntry,
  Releaf::I18nDatabase::I18nEntryTranslation
].each do |descendant|
  descendant.unscoped.delete_all
end

# Role {{{

puts "Creating roles"
role = Releaf::Permissions::Role.new(name: "super admin", default_controller: "releaf/permissions/users")
Releaf.application.config.available_controllers.each do|controller|
  role.permissions.build(permission: "controller.#{controller}")
end

role.save!

# }}}
# User {{{

puts "Creating users"
Releaf::Permissions::User.create!(
  name: 'Admin',
  surname: 'User',
  password: 'password',
  password_confirmation: 'password',
  locale: "en",
  email: 'admin@example.com',
  role: role,
)



# }}}
# Translations {{{

puts "Importing translations"
import_file_path = File.join(Gem.loaded_specs["releaf-i18n_database"].full_gem_path, "misc", "translations.xlsx")
translations = Releaf::I18nDatabase::ParseSpreadsheetTranslations.call(file_path: import_file_path, extension: "xlsx")
translations.each{|translation| translation.save! }

# }}}

# vim: set fdm=marker:
