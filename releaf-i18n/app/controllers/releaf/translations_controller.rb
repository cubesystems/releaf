module Releaf
  class TranslationsController < BaseController
    helper_method :locales, :localization

    def self.resource_class
      Releaf::Translation
    end

    def edit
      @collection = resources
      search(params[:search])
    end

    def export
      @collection = resources
      search(params[:search])

      respond_to do |format|
        format.xlsx do
          response.headers['Content-Disposition'] = "attachment; filename=\"translations.xlsx\""
        end
      end
    end

    def build_breadcrumbs
      super

      if %w[edit update].include?(params[:action]) && !params.has_key?(:import)
        @breadcrumbs << { name: I18n.t("edit translations", scope: controller_scope_name), url: url_for(action: :edit, search: params[:search]) }
      end
    end

    def load_translation key, localizations
      translation = Releaf::Translation.where(key: key).first_or_initialize
      translation.key = key

      localizations.each_pair do |locale, localization|
        load_translation_data(translation, locale, localization)
      end

      translation
    end

    def load_translation_data translation, locale, localization
      translation_data = translation.translation_data.find{ |x| x.lang == locale }
      # replace existing locale value only if new one is not blank
      if translation_data
        translation_data.localization = localization
      # always assign value for new locale
      elsif translation_data.nil?
        translation_data = translation.translation_data.build(lang: locale, localization: localization)
      end
    end

    def update
      @collection = []
      @translations_to_save = []

      valid = build_updatables(params[:translations])
      import_view if params.has_key?(:import)

      respond_to do |format|
        format.html do
          if valid
            process_updatables
            update_response_success
          else
            render_notification false, now: true
            render action: :edit
          end
        end
      end
    end

    def resources
      relation = super

      sql = '
      LEFT OUTER JOIN
        releaf_translation_data AS %s_data ON %s_data.translation_id = releaf_translations.id AND %s_data.lang = "%s"
      '

      Releaf.all_locales.each do |locale|
        relation = relation.joins(sql % ([locale] * 4))
      end

      relation.select(columns_for_select)
    end

    # overwrite leaf base class
    def search lookup_string
      unless lookup_string.blank?
        sql = search_column_names.map do |column|
          column_query = lookup_string.split(' ').map do |part|
            "#{column} LIKE '%#{part}%'"
          end.join(' AND ')
          "(#{column_query})"
        end.join(' OR ')

        @collection = @collection.where(sql)
      end
    end

    def import
      if File.exists? import_file_path
        @collection = Releaf::TranslationsImporter.new(import_file_path).parsed_output
        import_view
        render :edit
      else
        redirect_to action: :index
      end
    end

    protected

    def import_view
      @import = true
      @breadcrumbs << { name: I18n.t("import", scope: controller_scope_name) }
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

    def localization translation, locale
      locale_key = "#{locale}_localization"
      if translation.respond_to? locale_key
        translation.send(locale_key)
      else
        translation.translation_data.find{ |x| x.lang == locale }.try(:localization)
      end
    end

    private

    def process_updatables
      resource_class.where(id: @translation_ids_to_destroy).destroy_all unless @translation_ids_to_destroy.empty?
      @translations_to_save.map(&:save!)
      Settings.i18n_updated_at = Time.now
    end

    def build_updatables translations_params
      valid = true
      @translation_ids_to_destroy = params[:existing_translations].split(",")

      translations_params.each do |values|
        translation = load_translation(values["key"], values["localizations"])

        if translation.valid?
          @translations_to_save << translation
          @translation_ids_to_destroy.delete(translation.id.to_s)
        else
          valid = false
        end

        @collection << translation
      end

      valid
    end

    def search_column_names
      ['releaf_translations.key'] + Releaf.all_locales.map { |l| "%s_data.localization" % l }
    end

    def columns_for_select
      (['releaf_translations.*'] + localization_columns).join(', ')
    end

    def localization_columns
      Releaf.all_locales.map do |l|
        [
          "%s_data.localization AS %s_localization" % [l, l],
          "%s_data.id AS %s_localization_id" % [l, l]
        ]
      end.flatten
    end

    def update_response_success
      if @import
        msg = 'successfuly imported %{count} translations'
        flash[:success] = { id: :resource_status, message: I18n.t(msg, default: msg, count: @translations_to_save.size , scope: notice_scope_name) }
        redirect_to action: :index
      else
        render_notification true
        redirect_to action: :edit, search: params[:search]
      end
    end

    def import_file_path
      params[:import_file].try(:tempfile).try(:path).to_s
    end
  end
end
