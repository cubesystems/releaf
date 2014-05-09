module Releaf
  class TranslationsController < BaseController
    helper_method :locales

    def self.resource_class
      Releaf::Translation
    end

    def index
      load_collection do |collection|
        collection.page( params[:page] ).per_page( @resources_per_page )
      end
    end

    def edit
      load_collection
    end

    def build_breadcrumbs
      super

      if %w[edit update].include?(params[:action]) && !params.has_key?(:import)
        @breadcrumbs << { name: I18n.t("edit translations", scope: controller_scope_name), url: url_for(action: :edit, search: params[:search]) }
      end
    end

    def update
      @translation_collection = Releaf::TranslationCollection.update params[:translations]
      @collection = @translation_collection.collection
      success = @translation_collection.valid?

      @import = params.has_key?(:import)

      respond_to do |format|
        format.html do
          if success
            if @import
              render_notification true, success_message_key: 'successfuly imported translations'
              msg = 'successfuly imported %{count} translations'
              flash[:success] = { id: :resource_status, message: I18n.t(msg, default: msg, count: @collection.size , scope: notice_scope_name) }
              redirect_to action: :index
            else
              render_notification true
              redirect_to action: :edit, search: params[:search]
            end
          else
            render_notification false
            render action: :edit
            flash.delete(:error)
          end
        end
      end
    end

    def load_collection &block
      @translation_collection = Releaf::TranslationCollection.search params[:search]
      @collection = @translation_collection.collection
      @collection = yield(@collection) if block_given?
      @collection = @collection.map do |translation|
        Releaf::TranslationProxy.new(translation)
      end
    end

    def setup
      super
      @features = {:index => true}
      @searchable_fields = true
    end

    def fields_to_display
      ['key'] + locales
    end

    def locales
      Releaf.all_locales
    end


    def export
      respond_to do |format|
        format.xlsx do
          load_collection

          exporter = TranslationsExporter.new(@collection)
          send_data(exporter.output_as_string, filename: 'translations.xlsx')
        end
      end
    end

    def import
      if File.exists? import_file_path
        @collection = Releaf::TranslationsImporter.new(import_file_path).parsed_output

        @import = true
        @breadcrumbs << { name: I18n.t("import", scope: controller_scope_name) }
        render 'edit'
      else
        render_notification false
        redirect_to action: :index
      end
    end

    private

    def import_file_path
      params[:import_file].try(:tempfile).try(:path).to_s
    end
  end
end
