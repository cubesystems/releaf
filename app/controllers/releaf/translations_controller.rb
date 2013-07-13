module Releaf
  class TranslationsController < BaseController
    helper_method :locales

    def resource_class
      I18n::Backend::Releaf::TranslationGroup
    end

    def locales
      valid_locales = Releaf.available_locales || []
      valid_locales += Releaf.available_admin_locales || []
      valid_locales.uniq
    end

    def resource_class
      @object_class
    end

    def build_secondary_panel_variables
      @groups = I18n::Backend::Releaf::TranslationGroup.order(:scope).all
      super
    end

    def fields_to_display
      cols = super
      unless %w[index].include? params[:action]
        cols += (locales || [])
      end

      return cols
    end

    def create
      @resource = resource_class.new(resource_params)

      respond_to do |format|
        if @resource.save
          flash[:success] = I18n.t('created', :scope => 'notices.' + controller_scope_name)
          update_translations
          Settings.i18n_updated_at = Time.now
          format.html { redirect_to url_for(:action => "edit", :id => @resource.id) }
        else
          format.html { render :action => "new" }
        end
      end
    end

    def update
      @resource = resource_class.find(params[:id])

      unless params[:translations].blank?
        ids_to_keep = update_translations
        flash[:success] = I18n.t('updated', :scope => 'notices.' + controller_scope_name)
        @resource.translations.where('id NOT IN (?)', ids_to_keep).destroy_all
      else
        @resource.translations.destroy_all
      end
      Settings.i18n_updated_at = Time.now


      respond_to do |format|
        format.html { redirect_to url_for(:action => "edit", :id => @resource.id) }
      end
    end

    protected

    def setup
      super
      @object_class = I18n::Backend::Releaf::TranslationGroup
    end

    private

    def update_translations
      return [] if params[:translations].blank?

      ids_to_keep = [];
      params[:translations].each_pair do |id,t|
        next if t['key'].blank?

        translation = nil
        if id =~ /\A\d+\z/
          translation = I18n::Backend::Releaf::Translation.find(id)
        else
          translation = @resource.translations.new
        end

        translation.key = params[:translation_group][:scope] + '.' + t['key']
        translation.save


        unless id =~ /\A\d+\z/
          id = translation.id
        end

        ids_to_keep.push  id


        (locales || []).each do |locale|
          translation_data = I18n::Backend::Releaf::TranslationData.find_or_initialize_by_translation_id_and_lang(id, locale)
          unless t['localization'][locale].blank?
            translation_data.localization = t['localization'][locale]
            translation_data.save
          else
            translation_data.destroy
          end
        end
      end
      return ids_to_keep
    end

    def resource_params
      params.require(:resource).permit(:scope)
    end

  end
end
