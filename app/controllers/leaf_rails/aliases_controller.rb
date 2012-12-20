module LeafRails
  class AliasesController < BaseController

    def setup
      super
      @object_class = TranslationGroup
      @features[:show] = false
      @continuous_scroll = true
    end

    def current_object_class
      @object_class
    end

    def build_secondary_panel_variables
      @groups = TranslationGroup.order(:scope).all
      super
    end

    def columns( view = nil )
      return super + Settings.i18n_locales
    end

    def index
      # authorize! :manage, Translation
      @list = @object_class = Translation.includes(:translation_data)
    end

    def edit
      # authorize! :manage, Translation
      @item = current_object_class.find(params[:id])
    end

    def show
      # authorize! :manage, Translation
      redirect_to url_for( :action => "edit", :id => params[:id] )
    end

    def create
      # authorize! :manage, Translation
      @item = current_object_class.new(params[current_object_class_name])

      respond_to do |format|
        if @item.save
          format.html { redirect_to url_for(:action => "edit", :id => @item.id) }
        else
          format.html { render action => "new" }
        end
      end
    end

    def update
      # authorize! :manage, Translation
      @item = current_object_class.find(params[:id])

      if params[:translations]
        ids_to_keep = [];
        params[:translations].each_pair do |id,t|
          next if t['key'].blank?

          translation = nil
          if id =~ /\A\d+\z/
            translation = Translation.find(id)
          else
            translation = @item.translations.new
          end

          translation.key = params[:translation_group][:scope] + '.' + t['key']
          translation.save


          unless id =~ /\A\d+\z/
            id = translation.id
          end

          ids_to_keep.push  id


          Settings.i18n_locales.each do |locale|
            translation_data = TranslationData.find_or_initialize_by_translation_id_and_lang(id, locale)
            unless t['localization'][locale].blank?
              translation_data.localization = t['localization'][locale]
              translation_data.save
            else
              translation_data.destroy
            end
          end
        end


        @item.translations.where('id NOT IN (?)', ids_to_keep).destroy_all
      else
        @item.translations.destroy_all
      end


      respond_to do |format|
        format.html { redirect_to url_for(:action => "edit", :id => @item.id) }
      end
    end


    private

    def item_params
      params.require(current_object_class_name).permit(:scope)
    end

  end
end
