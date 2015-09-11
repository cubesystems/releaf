module Releaf::Core
  class AssetsResolver
    CONTROLLER_ASSET_PATTERN = /app\/assets\/(javascripts|stylesheets)\/((releaf\/)?controllers\/(.*?))\..*/

    def self.base_assets
      ["releaf/application"]
    end

    def self.controller_assets(controller, type)
      base_assets + list.fetch(controller, {}).fetch(type, [])
    end

    def self.scan
      list = {}

      Rails.application.assets.each_file do|file|
        match = file.to_s.match(CONTROLLER_ASSET_PATTERN)
        if match
          controller = match[4]
          if list[controller].nil?
            list[controller] = {stylesheets: [], javascripts: []}
          end
          list[controller][match[1].to_sym] << match[2]
        end
      end

      list
    end

    def self.list
      if Rails.env.development?
        scan
      else
        @@list ||= scan
      end
    end
  end
end
