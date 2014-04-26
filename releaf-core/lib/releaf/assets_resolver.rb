module Releaf
  class AssetsResolver
    CONTROLLER_ASSET_PATTERN = /app\/assets\/(javascripts|stylesheets)\/releaf\/controllers\/(.*?)\..*/

    def self.stylesheet_exists? controller
      list[:stylesheets].include? controller
    end

    def self.javascript_exists? controller
      list[:javascripts].include? controller
    end

    private

    def self.scan
      list = {
        javascripts: [],
        stylesheets: [],
      }

      Rails.application.assets.each_file do|file|
        match = file.to_s.match(CONTROLLER_ASSET_PATTERN)
        if match
          list[match[1].to_sym] << match[2]
        end
      end

      list
    end

    def self.list
      @@list ||= scan
    end
  end
end
