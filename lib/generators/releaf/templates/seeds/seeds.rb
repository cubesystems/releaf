# encoding: UTF-8

Releaf::Role.delete_all
Releaf::Admin.delete_all

Settings.delete_all

# Role {{{

# build all roles list
roles = {
  administrator: {
    name:     'administrator',
    permissions: Releaf.available_admin_controllers,
    default_controller: 'releaf/admins'
  },
  content_manager: {
    name:     'content manager',
    permissions: [
      'releaf/content'
    ],
    default_controller: 'releaf/content'
  }
}

roles.each_value do |value|
  role = Releaf::Role.new value
  puts role.errors.inspect unless role.valid?
  role.save!
  value[:id] = role.id
end

# }}}
# Admin {{{

puts "Creating admins"
admins = {
  admin: {
    name: 'Admin',
    surname: 'User',
    password: 'password',
    password_confirmation: 'password',
    locale: "en",
    email: 'admin@example.com',
    role_id: roles[:administrator][:id],
  },
  content_admin: {
    name: 'Simple',
    surname: 'User',
    password: 'password',
    password_confirmation: 'password',
    locale: "en",
    email: 'user@example.com',
    role_id: roles[:content_manager][:id]
  }
}

admins.each_value do |value|
  admin = Releaf::Admin.new(value)
  puts admin.errors.inspect unless admin.valid?
  admin.save!
  value[:id] = admin.id
end

# }}}
# Settings {{{

puts "Creating settings"
Settings.i18n_locales  = %w[en]
Settings.i18n_admin_locales  = %w[en]
Settings.email_from = "do_not_reply@example.com"

# }}}


# vim: set fdm=marker:
