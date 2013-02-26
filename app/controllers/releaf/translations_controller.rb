module Releaf
  class TranslationsController < BaseController

    def setup
      super
      @object_class = I18n::Backend::Releaf::TranslationGroup
      @features[:show] = false
      @continuous_scroll = true
    end

    def current_object_class
      @object_class
    end

    def build_secondary_panel_variables
      @groups = I18n::Backend::Releaf::TranslationGroup.order(:scope).all
      super
    end

    def columns( view = nil )
      return super + (Settings.i18n_locales || [])
    end

    def index
      authorize! :manage, I18n::Backend::Releaf::Translation
      @list = @object_class = I18n::Backend::Releaf::Translation.includes(:translation_data).filter(:search => params[:search])
      if !params[:ajax].blank?
        render :layout => false
      end
    end

    def edit
      authorize! :manage, I18n::Backend::Releaf::Translation
      @item = current_object_class.find(params[:id])
    end

    def show
      authorize! :manage, I18n::Backend::Releaf::Translation
      redirect_to url_for( :action => "edit", :id => params[:id] )
    end

    def create
      authorize! :manage, I18n::Backend::Releaf::Translation
      @item = current_object_class.new(item_params)

      respond_to do |format|
        if @item.save
          update_translations
          Settings.i18n_updated_at = Time.now
          format.html { redirect_to url_for(:action => "edit", :id => @item.id) }
        else
          format.html { render :action => "new" }
        end
      end
    end

    def update
      authorize! :manage, I18n::Backend::Releaf::Translation
      @item = current_object_class.find(params[:id])

      unless params[:translations].blank?
        ids_to_keep = update_translations
        @item.translations.where('id NOT IN (?)', ids_to_keep).destroy_all
      else
        @item.translations.destroy_all
      end
      Settings.i18n_updated_at = Time.now


      respond_to do |format|
        format.html { redirect_to url_for(:action => "edit", :id => @item.id) }
      end
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
          translation = @item.translations.new
        end

        translation.key = params[:translation_group][:scope] + '.' + t['key']
        translation.save


        unless id =~ /\A\d+\z/
          id = translation.id
        end

        ids_to_keep.push  id


        (Settings.i18n_locales || []).each do |locale|
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

    def item_params
      params.require(:item).permit(:scope)
    end

  end
end
