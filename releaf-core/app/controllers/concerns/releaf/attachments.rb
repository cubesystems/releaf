module Releaf
  module Attachments
    extend ActiveSupport::Concern

    included do
      helper_method :attachment_upload_url
    end

    def new_attachment
      render :layout => nil
    end

    def attachment_upload_url
      url_for(:action => 'new_attachment')
    rescue
      ''
    end

    def create_attachment
      @resource = Attachment.new
      if params[:file]
        @resource.file_type = params[:file].content_type
        @resource.file  = params[:file]
        @resource.title = params[:title] if params[:title].present?
        @resource.save!

        partial = case @resource.type
                  when 'image' then 'image'
                  else
                    'link'
                  end
        render :partial => "attachment_#{partial}", :layout => nil
      else
        render :text => ''
      end
    end
  end
end
