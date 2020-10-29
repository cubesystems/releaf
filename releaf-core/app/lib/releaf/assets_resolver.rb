module Releaf
  class AssetsResolver
    NONCOMPILED_PATTERN = /(javascripts|stylesheets)\/(controllers\/(.*?))\..*/
    COMPILED_PATTERN = /controllers\/(.*?)\.(js|css)$/
    TYPE_EXTENSION_MAP = {
      "stylesheets" => "css",
      "javascripts" => "js",
    }

    def self.base_assets
      ["releaf/application"]
    end

    def self.controller_assets(controller, type)
      asset_path = "controllers/#{controller}.#{TYPE_EXTENSION_MAP[type.to_s]}"
      base_assets + [assets[asset_path]].compact
    end

    def self.noncompiled_assets
      Rails.application.assets.each_file.map do|file|
        match = file.to_s.match(NONCOMPILED_PATTERN)
        "#{match[2]}.#{TYPE_EXTENSION_MAP[match[1]]}" if match
      end.compact
    end

    def self.compiled_assets
      Rails.application.assets_manifest.files.map do|_, asset|
        match = asset["logical_path"].match(COMPILED_PATTERN)
        asset["logical_path"] if match
      end.compact.uniq
    end

    def self.compiled_assets?
      Rails.application.assets.nil?
    end

    def self.assets_hash(assets)
      assets.inject({}) do|hash, asset|
        hash.update(asset => asset)
      end
    end

    def self.assets
      if compiled_assets?
        @@compiled_assets ||= assets_hash(compiled_assets)
      else
        assets_hash(noncompiled_assets)
      end
    end
  end
end
