# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ActiveRecord::Base.descendants.each do |descendant|
  next if descendant.abstract_class?
  next if descendant.name =~ /^ActiveRecord\:\:/
  next unless descendant.table_exists?
  descendant.unscoped.delete_all
end

# Role {{{

# build all roles list
roles = {
  administrator: {
    name:     'administrator',
    permissions: Releaf.available_controllers,
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

# vim: set fdm=marker:

