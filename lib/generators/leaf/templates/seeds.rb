# encoding: UTF-8

Role.delete_all
Admin.delete_all

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
  value[:id] = Role.create!(value).id
end

# }}}
# Admin {{{

puts "Creating admins"
admins = {
  admin: {
    name: 'admin',
    surname: 'admin',
    password: 'password',
    password_confirmation: 'password',
    email: 'example@example.com',
    role_id: roles[:admins][:id],
  },
  janis: {
    name: 'Jānis',
    surname: 'Ozoliņš',
    password: 'LetMeIn',
    password_confirmation: 'LetMeIn',
    email: 'janis@example.com',
    role_id: roles[:default][:id]
  }
}

admins.each_value do |value|
  value[:id] = Admin.create!(value).id
end

# }}}
# Settings {{{

puts "Creating settings"
Settings.i18n_locales  = %w[lv en ru]
Settings.email_from = "do_not_reply@siltumtehnika.cubesystems.lv"

# }}}


# vim: set fdm=marker:
