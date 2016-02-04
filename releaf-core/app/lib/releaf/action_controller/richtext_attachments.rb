module Releaf::ActionController::RichtextAttachments
  extend ActiveSupport::Concern

  included do
    skip_before_action :verify_authenticity_token, only: [:create_releaf_richtext_attachment]
  end

  def releaf_richtext_attachment_upload_url
    begin
      url_for(action: :create_releaf_richtext_attachment)
    rescue ::ActionController::UrlGenerationError
      nil
    end
  end

  def create_releaf_richtext_attachment
    return unless params[:upload]
    @resource = Releaf::RichtextAttachment.create!(file_type: params[:upload].content_type, file: params[:upload])
  end
end
