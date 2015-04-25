require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module Releaf
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr =  ActiveRecord::Generators::Base.next_migration_number(path).to_i
        else
          @prev_migration_nr += 1
        end

        @prev_migration_nr.to_s
      end

      source_root File.expand_path('../templates', __FILE__)

      def install_devise
        # prevent dummy app from installing devise one more time
        if self.class == Releaf::Generators::InstallGenerator
          generate "devise:install"
          generate "dragonfly"
        end
      end

      def install_initializer
        copy_files 'initializers', 'config/initializers'
      end

      def install_migrations
        get_file_list('migrations').each do |migration|
          migration_template "migrations/#{migration}", "db/migrate/#{migration}"
        end
      end

      def install_seeds
        seed_path = File.expand_path('../templates', __FILE__) + "/seeds/seeds.rb"
        append_to_file 'db/seeds.rb', File.read(seed_path)
      end

      def install_models
        copy_files 'models', 'app/models'
      end

      def install_configs
        copy_files 'config', 'config'
      end

      def install_views
        copy_files 'views', 'app/views'
      end

      def install_builders
        copy_files 'builders', 'app/builders'
      end

      def install_controllers
        copy_files 'controllers', 'app/controllers'
      end

      private

      def copy_files subdir, dest_dir
        raise ArgumEnterror unless subdir.is_a? String
        raise ArgumEnterror unless dest_dir.is_a? String
        raise ArgumetnError if subdir.blank?
        raise ArgumetnError if dest_dir.blank?

        get_file_list(subdir).each do |image|
          copy_file [subdir, image].join('/'), [dest_dir, image].join('/')
        end
      end

      def get_file_list subdir
        raise ArgumentError unless subdir.is_a? String
        raise ArgumetnError if subdir.blank?
        dir = get_current_dir
        search_path = [dir, 'templates', subdir].join('/') + '/'
        file_list = Dir.glob(search_path + '**/*').map { |filename| File.directory?(filename) ? nil : filename.sub(search_path, '') }
        file_list.delete nil
        return file_list
      end

      def get_current_dir
        File.dirname(__FILE__)
      end
    end
  end
end
