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
          copy_file "initializers/#{initializer}.rb", "config/initializers/#{initializer}.rb"
        end
      end

      def install_migrations
        %w[create_releaf_nodes create_releaf_roles create_releaf_translations create_releaf_admins].each do |migration|
          migration_template "migrations/#{migration}.rb", "db/migrate/#{migration}.rb"
        end
      end

      def install_seeds
        copy_file "seeds.rb", "db/seeds.rb"
      end

      def install_models
        %w[admin_ability].each do |model|
          copy_file "models/#{model}.rb", "app/models/#{model}.rb"
        end
      end

      def install_configs
        copy_file "config/common_fields.yml.example", "config/common_fields.yml.example"
      end

      def install_views
        %w[layouts/application home/index].each do |view|
          copy_file "views/#{view}.html.haml", "app/views/#{view}.html.haml"
        end
      end

      def install_controllers
        copy_file 'controllers/home_controller.rb', 'app/controllers/home_controller.rb'
      end

      def install_stylesheets
        %w[application.scss 3rd_party/reset.css 3rd_party/jquery_ui/smoothness.css.erb].each do |css|
          copy_file "stylesheets/#{css}", "app/assets/stylesheets/#{css}"
        end
      end

      def install_javascripts
        %w[application 3rd_party/jquery_ui].each do |js|
          copy_file "javascripts/#{js}.js", "app/assets/javascripts/#{js}.js"
        end
      end

      def install_images
        %w[
          3rd_party/jquery_ui/smoothness/ui-bg_glass_75_dadada_1x400.png
          3rd_party/jquery_ui/smoothness/ui-icons_222222_256x240.png
          3rd_party/jquery_ui/smoothness/ui-icons_cd0a0a_256x240.png
          3rd_party/jquery_ui/smoothness/ui-bg_glass_95_fef1ec_1x400.png
          3rd_party/jquery_ui/smoothness/ui-icons_888888_256x240.png
          3rd_party/jquery_ui/smoothness/ui-bg_highlight-soft_75_cccccc_1x100.png
          3rd_party/jquery_ui/smoothness/ui-bg_flat_0_aaaaaa_40x100.png
          3rd_party/jquery_ui/smoothness/ui-icons_2e83ff_256x240.png
          3rd_party/jquery_ui/smoothness/ui-bg_glass_65_ffffff_1x400.png
          3rd_party/jquery_ui/smoothness/ui-icons_454545_256x240.png
          3rd_party/jquery_ui/smoothness/ui-bg_glass_55_fbf9ee_1x400.png
          3rd_party/jquery_ui/smoothness/ui-bg_flat_75_ffffff_40x100.png
          3rd_party/jquery_ui/smoothness/ui-bg_glass_75_e6e6e6_1x400.png
        ].each do |image|
          copy_file "images/#{image}", "app/assets/images/#{image}"
        end

      end

    end
  end
end
