[
  Releaf::Permissions::User,
  Releaf::Permissions::Role,
  Releaf::Permissions::Permission
].each do |descendant|
  descendant.unscoped.delete_all
end

# Role {{{

puts "Creating roles"
super_admin = Releaf::Permissions::Role.new(name: "super admin", default_controller: "releaf/permissions/users")
Releaf.application.config.available_controllers.each do|controller|
  super_admin.permissions.build(permission: "controller.#{controller}")
end
super_admin.save!

content_manager = Releaf::Permissions::Role.new(name: "content manager", default_controller: "releaf/content/nodes")
content_manager.permissions.build(permission: "controller.releaf/content/nodes")
content_manager.save!

# }}}
# User {{{

puts "Creating users"
users = {
  user: {
    name: 'Admin',
    surname: 'User',
    password: 'password',
    password_confirmation: 'password',
    locale: "en",
    email: 'admin@example.com',
    role: super_admin,
  },
  simple_user: {
    name: 'Simple',
    surname: 'User',
    password: 'password',
    password_confirmation: 'password',
    locale: "en",
    email: 'user@example.com',
    role: content_manager,
  }
}

users.each_value do |attributes|
  Releaf::Permissions::User.create!(attributes)
end

# }}}

# vim: set fdm=marker:

