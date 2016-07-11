[
  Releaf::Permissions::User,
  Releaf::Permissions::Role,
  Releaf::Permissions::Permission
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

# vim: set fdm=marker:
