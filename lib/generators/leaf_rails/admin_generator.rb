module LeafRails
  module Generators
    class AdminGenerator < Rails::Generators::Base
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

      def install_migrations
        %w[create_roles create_admins].each do |migration|
          migration_template "migrations/#{migration}.rb", "db/migrate/#{migration}.rb"
        end
      end


      def install_models
        %w[admin admin_ability role].each do |model|
          template "models/#{model}.rb", "app/models/#{model}.rb"
        end
      end

      def install_controllers
        %w[admins roles].each do |controller|
          template "controllers/#{controller}_controller.rb", "app/controllers/admin/#{controller}_controller.rb"
        end
      end

      def install_roles_views
        %w[_edit.field.permissions.haml _show.field.permissions.haml].each do |view|
          template "views/roles/#{view}", "app/views/admin/roles/#{view}"
        end
      end

      def install_admins_views
        %w[
          _edit.field.password.haml
          _edit.field.password_confirmation.haml
          _edit.field.role_id.haml
          _index.cell.role_id.haml
          _show.field.role_id.haml
        ].each do |view|
          template "views/admins/#{view}", "app/views/admin/admins/#{view}"
        end
      end

    end
  end
end
