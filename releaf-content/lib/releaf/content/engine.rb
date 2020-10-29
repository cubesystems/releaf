module Releaf::Content
  class Engine < ::Rails::Engine
    initializer 'releaf_content.assets_precompile', group: :all do |app|
      app.config.assets.precompile << "releaf_content_manifest.js"
    end
  end
end
