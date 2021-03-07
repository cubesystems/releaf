require 'rbconfig'
require 'yaml'

config_file = File.expand_path('../../../config.yml', __FILE__)
config = YAML.load_file(config_file)


gsub_file "config/database.yml", /database: dummy_/, "database: #{config["database"]["name"]}_"
gsub_file "config/database.yml", /username: .*/, "username: #{config["database"]["username"]}"
gsub_file "config/database.yml", /default: &default/, "default: &default\n  username: #{config["database"]["username"]}"
if config["database"]["password"].present?
  gsub_file "config/database.yml", /password:/, "password: #{config["database"]["password"]}"
end

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
gsub_file 'config/environments/development.rb', 'config.assets.debug = true', 'config.assets.debug = false'
rake 'db:create'

generate "releaf:install"
generate "dummy:install -f"

application "config.i18n.fallbacks = true"
application "config.i18n.enforce_available_locales = true"

# in "test" env "true" cause to fail on install generators, revert to normall
gsub_file 'config/environments/test.rb', 'config.cache_classes = false', 'config.cache_classes = true'
gsub_file 'config/environments/test.rb', 'config.action_controller.allow_forgery_protection = false', 'config.action_controller.allow_forgery_protection = true'
rake 'db:migrate'
rake 'db:seed'

ENV['RAILS_ENV'] = 'test'
rake 'db:create'
rake 'db:migrate'
