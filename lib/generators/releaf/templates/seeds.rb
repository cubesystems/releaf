# encoding: UTF-8

Releaf::Role.delete_all
Releaf::Admin.delete_all

Settings.delete_all

# Role {{{

puts "Creating roles"
roles = {
  default: {
    name:     'default role',
    default:  true
  },
  admins: {
    name:     'admins',
    default:  false,
    admin_permission: true
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
    email: 'admin@example.com',
    role_id: roles[:admins][:id],
  },
  janis: {
    name: 'Simple',
    surname: 'User',
    password: 'LetMeIn',
    password_confirmation: 'LetMeIn',
    email: 'user@example.com',
    role_id: roles[:default][:id]
  }
}

admins.each_value do |value|
  value[:id] = Releaf::Admin.create!(value).id
end

# }}}
# Settings {{{

puts "Creating settings"
Settings.i18n_locales  = %w[en]
Settings.email_from = "do_not_reply@example.com"

# }}}


# vim: set fdm=marker:
