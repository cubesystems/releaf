module Releaf
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      class_option :rvm,  :type => :boolean, :aliases => nil, :group => :runtime, :default => true,
                           :desc => "Install with rvm gemset support"

      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        else
          @prev_migration_nr += 1
        end
        @prev_migration_nr.to_s
      end

      source_root File.expand_path('../templates', __FILE__)

      def install_initializer
        %w[releaf releaf_store_current_template releaf_i18n].each do |initializer|
          template "initializers/#{initializer}.rb", "config/initializers/#{initializer}.rb"
        end
      end

      def install_migrations
        %w[create_releaf_nodes create_releaf_roles create_releaf_translations create_releaf_admins].each do |migration|
          migration_template "migrations/#{migration}.rb", "db/migrate/#{migration}.rb"
        end
      end

      def install_seeds
        template "seeds.rb", "db/seeds.rb"
      end

      def install_models
        %w[admin_ability].each do |model|
          template "models/#{model}.rb", "app/models/#{model}.rb"
        end
      end

      def install_configs
        template "config/common_fields.yml.example", "config/common_fields.yml.example"
      end

      def install_views
        template "views/layouts/application.html.haml", "app/views/layouts/application.html.haml"
      end

    end
  end
end
