module Releaf::RichtextAttachments
  module ActionController
    extend ActiveSupport::Concern

    included do
      skip_before_action :verify_authenticity_token, only: [:create_releaf_richtext_attachment]
    end

    def releaf_richtext_attachment_upload_url
      url_for(action: :create_releaf_richtext_attachment)
    end

    def create_releaf_richtext_attachment
      return unless params[:upload]
      @resource = Releaf::RichtextAttachment.new
      @resource.file_type = params[:upload].content_type
      @resource.file = params[:upload]
      @resource.save!
    end
  end
end
