require 'rbconfig'

def ask_wizard(question, default_value)
  value = ask (@current_recipe || "prompt").rjust(10) + "  #{question}"

  if value.blank?
    value = default_value
  end

  return value
end

# collect dummy database config
if ENV['RELEAF_DUMMY_DB_USERNAME'].nil?
  db_username = ask_wizard("Database username? (leave blank to use the 'root')", 'root')
else
  db_username = ENV['RELEAF_DUMMY_DB_USERNAME']
end

if ENV['RELEAF_DUMMY_DB_PASSWORD'].nil?
  db_password = ask_wizard("Database password for '#{db_username}?'", '')
else
  db_password = ENV['RELEAF_DUMMY_DB_PASSWORD']
end

if ENV['RELEAF_DUMMY_DB_NAME'].nil?
  @current_recipe = "database"
  db_name = ask_wizard("MySQL database name (leave blank to use 'releaf_dummy')?", 'releaf_dummy')
else
  db_name = ENV['RELEAF_DUMMY_DB_NAME']
end

gsub_file "config/database.yml", /username: .*/, "username: #{db_username}"
gsub_file "config/database.yml", /database: dummy_/, "database: #{db_name}_"
gsub_file "config/database.yml", /password:/, "password: #{db_password}" unless db_password.blank?

gsub_file 'config/boot.rb', "'../../Gemfile'", "'../../../../Gemfile'"

files_to_remove = %w[
  public/index.html
  public/images/rails.png
  app/views/layouts/application.html.erb
  config/routes.rb
  app/assets/stylesheets/application.css
  app/assets/javascripts/application.js
]
run "rm -f #{files_to_remove.join(' ')}"

run 'rm -f "Gemfile" "public/robots.txt" ".gitignore"'
# in "test" env "true" cause to fail on install generators
gsub_file 'config/environments/test.rb', 'config.cache_classes = true', 'config.cache_classes = false'
rake 'db:create'

generate "releaf:install"
generate "dummy:install -f"

application "config.i18n.fallbacks = true"
application "config.i18n.enforce_available_locales = true"

# in "test" env "true" cause to fail on install generators, revert to normall
gsub_file 'config/environments/test.rb', 'config.cache_classes = false', 'config.cache_classes = true'
rake 'db:migrate'
rake 'db:seed'

ENV['RAILS_ENV'] = 'test'
rake 'db:create'
rake 'db:migrate'
