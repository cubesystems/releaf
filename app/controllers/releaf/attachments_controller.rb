module Releaf
  class AttachmentsController < BaseController
    def new
      render :layout => nil
    end

    def create
      @resource = resource_class.new
      @resource.file_type = params[:file].content_type
      @resource.file = params[:file]
      @resource.save!

      render_template
    end

    def resource_class
      Releaf::Attachment
    end

    protected

    def render_template
      partial = case @resource.type
                when 'image' then 'image'
                else 
                  'link'
                end
      render :partial => partial, :layout => nil
    end


    def setup
      super
      @features = {
        edit:              false,
        edit_ajax_reload:  false,
        create:            true,
        destroy:           true,
        index:             false,
        # enable toolbox for each table row
        # it can be unnecessary for read only report like indexes
        index_row_toolbox: false
      }
      @upload_url = releaf_new_attachment_path
    end
  end
end
