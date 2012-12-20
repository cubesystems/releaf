module LeafRails
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
        template 'initializers/leaf_rails.rb', 'config/initializers/leaf_rails.rb'
        template 'initializers/store_current_template.rb', 'config/initializers/store_current_template.rb'
      end


      def install_migrations
        migration_template 'migrations/create_leaf_rails_nodes.rb', 'db/migrate/create_leaf_rails_nodes.rb'
      end
    end
  end
end
