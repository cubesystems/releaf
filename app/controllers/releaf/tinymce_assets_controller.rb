module Releaf
  class TinymceAssetsController < BaseController
    skip_authorization_check :only => [:create]

    def create
      asset = TinymceAsset.new
      asset.file_type = params[:file].content_type
      asset.file = params[:file]
      asset.save!


      render json: {
        image: {
          # url: serve_tinymce_asset_path(asset)
          url: asset.file.url
        }
      }, content_type: "text/html"
    end

    # def serve
    #   asset = TinymceAsset.find(params[:id])
    #   send_file asset.file.path, :type => asset.file_type
    # end

  end
end
