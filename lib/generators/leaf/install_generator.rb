module Leaf
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

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
        %w[leaf leaf_store_current_template leaf_i18n].each do |initializer|
          template "initializers/#{initializer}.rb", "config/initializers/#{initializer}.rb"
        end
      end

      def install_migrations
        %w[create_leaf_nodes create_leaf_roles create_leaf_translations create_leaf_admins].each do |migration|
          migration_template "migrations/#{migration}.rb", "db/migrate/#{migration}.rb"
        end
      end

      def install_seeds
        template "seeds.rb", "db/seeds.rb"
      end

      def install_models
        %w[admin admin_ability role].each do |model|
          template "models/#{model}.rb", "app/models/#{model}.rb"
        end
      end

      def install_configs
        template "config/common_fields.yml.example", "config/common_fields.yml.example"
      end

    end
  end
end
