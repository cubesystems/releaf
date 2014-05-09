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
      load_collection

      require( 'axlsx' )

      # construct xlsx file
      p = Axlsx::Package.new
      # Numbers requires this
      p.use_shared_strings = true

      add_group_to_workbook(p)

      respond_to do |format|
        format.xlsx do
          outstrio = StringIO.new
          outstrio.write(p.to_stream.read)
          send_data(outstrio.string, filename: 'translations.xlsx')
        end
      end
    end

    def import
      @collection = []

      file_path = params[:import_file].try(:tempfile).try(:path).to_s

      if File.exists? file_path
        assign_imported_data(file_path)
        @import = true
        @breadcrumbs << { name: I18n.t("import", scope: controller_scope_name) }
        render 'edit'
      else
        render_notification false
        redirect_to action: :index
      end
    end

    private

    def assign_imported_data file_path
      require "roo"
      xls = Roo::Excelx.new(file_path, file_warning: :ignore)

      xls.each_with_pagename do |name, sheet|
        locales = []
        sheet.row(1).each_with_index do |cell, i|
          if i > 0
            locales.push(cell)
          end
        end

        # iterate over data
        (2..sheet.last_row).each do |row_no|
          item = {}
          key = nil
          sheet.row(row_no).each_with_index do |cell, i|
            if i == 0
              key = cell
            else
              item[ locales[ i - 1 ] ] = cell.nil? ? '' : cell
            end
          end

          if key.present?
            translation = Releaf::TranslationProxy.new
            translation.key = key
            translation.localizations = item
            @collection.push translation
          end
        end
      end
    end

    def add_group_to_workbook(p)
      sheet = p.workbook.add_worksheet(name: 'localization')

      # title row
      row = [ '' ]
      locales.each do |locale|
        row.push(locale)
      end

      xls_row = sheet.add_row(row)

      @collection.each do |translation|
        row = [ translation.key ]
        locales.each do |locale|
          row.push(translation.localizations[locale])
        end

        xls_row = sheet.add_row(row)
      end

      return sheet
    end
  end
end
