module Releaf::Content
  class Engine < ::Rails::Engine
    initializer 'precompile', group: :all do |app|
      app.config.assets.precompile += %w(controllers/releaf/content/*)
    end
  end
end
