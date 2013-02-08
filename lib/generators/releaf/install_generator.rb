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
        copy_files 'initializers', 'config/initializers'
      end

      def install_migrations
        get_file_list('migrations').each do |migration|
          migration_template "migrations/#{migration}", "db/migrate/#{migration}"
        end
      end

      def install_seeds
        copy_file "seeds.rb", "db/seeds.rb"
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

      def install_controllers
        copy_file 'controllers/home_controller.rb', 'app/controllers/home_controller.rb'
      end

      def install_stylesheets
        copy_files 'stylesheets', 'app/assets/stylesheets'
      end

      def install_javascripts
        copy_files 'javascripts', 'app/assets/javascripts'
      end

      def install_images
        copy_files 'images', 'app/assets/images'
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
        dir = File.dirname(__FILE__)
        search_path = [dir, 'templates', subdir].join('/') + '/'
        file_list = Dir.glob(search_path + '**/*').map { |filename| File.directory?(filename) ? nil : filename.sub(search_path, '') }
        file_list.delete nil
        return file_list
      end

    end
  end
end
