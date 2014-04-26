module Releaf
  class TranslationsController < BaseController
    helper_method :locales

    def self.resource_class
      I18n::Backend::Releaf::TranslationGroup
    end

    def setup
      super
      @searchable_fields = [:scope, {:translations => [:key, {:translation_data => [:localization]} ] } ]
    end

    def locales
      valid_locales = Releaf.available_locales || []
      valid_locales += Releaf.available_admin_locales || []
      valid_locales.uniq
    end

    def create
      Settings.i18n_updated_at = Time.now
      super
    end

    def destroy
      Settings.i18n_updated_at = Time.now
      super
    end

    def update
      Settings.i18n_updated_at = Time.now
      super
    end

    def export
      @resource = resource_class.find(params[:id])

      require( 'axlsx' )

      # construct xlsx file
      p = Axlsx::Package.new
      # Numbers requires this
      p.use_shared_strings = true

      add_group_to_workbook(@resource, p)

      respond_to do |format|
        format.xlsx do
          outstrio = StringIO.new
          outstrio.write(p.to_stream.read)
          send_data(outstrio.string, filename: @resource.scope + '.xlsx')
        end
      end
    end

    # TODO: perhaps change this into a collection method
    def import
      @resource = resource_class.find(params[:id])

      json = { sheets: {} }

      require "roo"
      xls = Roo::Excelx.new(params[:resource][:import_file].tempfile.path, file_warning: :ignore)

      xls.each_with_pagename do |name, sheet|
        json[:sheets][name] = {}
        # read locales
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

          if !key.blank?
            json[:sheets][name][key] = item
          end
        end
      end

      respond_to do |format|
        format.json do
          render json: json, layout: false
        end
      end
    end

    private

    def resource_params
      return [] unless %w[update create].include? params[:action]
      return super + [{translations_attributes: [:id, :_destroy, :key, {translation_data_attributes: [:id, :lang, :localization]}]}]
    end

    def add_group_to_workbook(group, p)
      sheet = p.workbook.add_worksheet(name: group.scope[0..15])

      # title row
      row = [ '' ]
      locales.each do |locale|
        row.push(locale)
      end

      xls_row = sheet.add_row(row)

      group.translations.each do |translation|
        row = [ translation.plain_key ]
        locales.each do |locale|
          row.push(translation.locales[locale])
        end

        xls_row = sheet.add_row(row)
      end

      return sheet
    end
  end
end