require File.expand_path('../../releaf/install_generator', __FILE__)

module Dummy
  module Generators
    class InstallGenerator < Releaf::Generators::InstallGenerator
      @dummy_generator = true

      source_root File.expand_path('../templates', __FILE__)

      def install_seeds
        super
        # add seeds from dummy folder also
        seed_path = File.expand_path('../templates', __FILE__) + "/seeds/seeds.rb"
        append_to_file 'db/seeds.rb', File.read(seed_path)
      end

      def install_assets
        copy_files 'assets', 'app/assets'
        append_file 'config/initializers/assets.rb', "Rails.application.config.assets.precompile += %w( controllers/*.css controllers/*.js )\n"
      end

      private

      def get_current_dir
        File.dirname(__FILE__)
      end

    end
  end
end
