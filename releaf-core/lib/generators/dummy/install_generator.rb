require File.expand_path('../../releaf/install_generator', __FILE__)

module Dummy
  module Generators
    class InstallGenerator < Releaf::Generators::InstallGenerator
      @dummy_generator = true

      source_root File.expand_path('../templates', __FILE__)

      def install_assets
        copy_files 'assets', 'app/assets'
      end

      def install_seeds; end

      private

      def get_current_dir
        File.dirname(__FILE__)
      end

    end
  end
end
