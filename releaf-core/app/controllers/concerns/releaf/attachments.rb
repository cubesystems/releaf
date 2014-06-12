module Releaf
  module Attachments
    extend ActiveSupport::Concern

    included do
      helper_method :attachment_upload_url
      skip_before_action :verify_authenticity_token, only: [:create_attachment]
    end

    def attachment_upload_url
      url_for(action: 'create_attachment')
    rescue
      ''
    end

    def create_attachment
      @resource = Attachment.new
      if params[:upload]
        @resource.file_type = params[:upload].content_type
        @resource.file  = params[:upload]
        @resource.save!
      end
    end
  end
end
