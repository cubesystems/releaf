# encoding: UTF-8

Releaf::Role.delete_all
Releaf::Admin.delete_all

Settings.delete_all

# Role {{{

# set max permissions for administrator role
administrator = {
  name:     'administrator',
}

Releaf.available_admin_controllers.each do |controller_name|
  permission = controller_name.gsub("/", "_") + "_permission"
  administrator[permission] = true
end

# build all roles list
roles = {
  administrator: administrator,
  content_manager: {
    name:     'content manager',
    releaf_content_permission: true
  }
}

roles.each_value do |value|
  value[:id] = Releaf::Role.create!(value).id
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
  value[:id] = Releaf::Admin.create!(value).id
end

# }}}
# Settings {{{

puts "Creating settings"
Settings.i18n_locales  = %w[en]
Settings.i18n_admin_locales  = %w[en]
Settings.email_from = "do_not_reply@example.com"

# }}}


# vim: set fdm=marker:
