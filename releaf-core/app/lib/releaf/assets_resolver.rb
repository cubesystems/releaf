module Releaf
  class AssetsResolver
    NONCOMPILED_PATTERN = /app\/assets\/(javascripts|stylesheets)\/((releaf\/)?controllers\/(.*?))\..*/
    COMPILED_PATTERN = /(releaf\/)?controllers\/(.*?)\.(js|css)$/

    def self.base_assets
      ["releaf/application"]
    end

    def self.controller_assets(controller, type)
      base_assets + assets.fetch(controller, {}).fetch(type, [])
    end

    def self.noncompiled_assets
      list = {}

      Rails.application.assets.each_file do|file|
        match = file.to_s.match(NONCOMPILED_PATTERN)
        if match
          controller = match[4]
          asset_type = match[1].to_sym
          list[controller] ||= {stylesheets: [], javascripts: []}
          list[controller][asset_type] << match[2]
        end
      end

      list
    end

    def self.compiled_assets
      list = {}

      Rails.application.assets_manifest.files.each_pair do|asset_path, asset|
        match = asset["logical_path"].match(COMPILED_PATTERN)
        if match
          controller = match[2]
          asset_type = match[3] == "css" ? :stylesheets : :javascripts
          list[controller] ||= {stylesheets: [], javascripts: []}
          list[controller][asset_type] << asset["logical_path"]
        end
      end

      list
    end

    def self.compiled_assets?
      Rails.application.assets.nil?
    end

    def self.assets
      if compiled_assets?
        @@compiled_assets ||= compiled_assets
      else
        noncompiled_assets
      end
    end
  end
end
