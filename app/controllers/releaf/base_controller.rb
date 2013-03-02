module Releaf
  class FeatureDisabled < StandardError; end

  class BaseController < BaseApplicationController
    helper_method :build_secondary_panel_variables,
      :fields_to_display,
      :current_object_class,
      :find_parent_template,
      :has_template?,
      :list_action,
      :render_field_type,
      :render_parent_template,
      :secondary_panel,
      :current_feature

    before_filter do
      filter_templates
      set_locale
      setup
    end


    # Helper that returns current feature
    def current_feature
      case params[:action].to_sym
      when :index
        return :intex
      when :new, :create
        return :create
      when :edit, :update
        return :edit
      when :destroy, :confirm_destroy
        return :destroy
      else
        return params[:action].to_sym
      end
    end


    def autocomplete
      authorize! :edit, current_object_class

      c_obj = current_object_class

      if params[:query_field] and params[:q] and params[:field] #and params[:field] =~ /_id\z/ and c_obj.column_names.include?(params[:field]) and c_obj.respond_to?(:reflect_on_association) and c_obj.reflect_on_association(params[:field].sub(/_id\z/, '').to_sym)

        obj = c_obj.reflect_on_association(params[:field].sub(/_id\z/, '').to_sym).klass
        obj_fields = obj.column_names

        sql = []
        sql_params = {}

        params[:q].split(' ').each_with_index do |part, i|
          sql.push "#{params[:query_field]} LIKE :part#{i}"
          sql_params[:"part#{i}"] = "%#{part}%"
        end

        order_by = nil

        if params[:order]
          order_by = []

          params[:order].split(',').each do |order_part|
            if obj_fields.include? order_part.sub(/ (asc|desc)\z/i, '')
              order_by.push order_part
            end
          end
        end

        order_by = [params[:query_field],'id'] if order_by.blank?

        query = obj.where(sql.join(' AND '), sql_params).order(order_by.join(', '))

        matching_items_count = query.count
        list = query.limit(20)

        @items = []
        list.each do |item|
          @items.push({ :id => item.id, :text => item.to_text })
        end

        respond_to do |format|
          format.json { render :json => {:matching_items_count => matching_items_count, :query => params[:q], :results => @items } }
        end

      else
        respond_to do |format|
          format.json { raise }
        end
      end
    end

    def index
      authorize! :list, current_object_class
      if current_object_class.respond_to? :filter
        @items = current_object_class.filter(:search => params[:search])
      else
        @items = current_object_class
      end

      if current_object_class.respond_to? :order_by
        @items = @items.order_by(valid_order_by)
      end

      @items = @items.includes(relations_for_includes).page( params[:page] ).per_page( @items_per_page )

      unless params[:ajax].blank?
        render :layout => false
      end
    end

    def urls
      respond_to do |format|
        format.json do
          json = {}
          params[:ids].each do |id|
            json[id] = url_for( :action => params[:to_action], :id => id, :only_path => true )
          end
          render :json => json, :layout => false
        end
      end
    end

    def new
      authorize! :create, current_object_class
      raise FeatureDisabled unless @features[:create]
      @item = current_object_class.new
    end

    def show
      @item = current_object_class.includes(relations_for_includes).find(params[:id])
      authorize! :show, @item
      raise FeatureDisabled unless @features[:show]
    end

    def edit
      @item = current_object_class.includes(relations_for_includes).find(params[:id])
      authorize! :edit, @item
      raise FeatureDisabled unless @features[:edit]
    end

    def create
      authorize! :create, current_object_class
      raise FeatureDisabled unless @features[:create]

      @item = current_object_class.new

      @item.assign_attributes( allowed_params )

      respond_to do |format|
        if @item.save
          format.html { redirect_to url_for( :action => @features[:show] ? 'show' : 'index', :id => @item.id ) }
        else
          format.html { render :action => "new" }
        end
      end
    end

    def update
      @item = current_object_class.find(params[:id])
      authorize! :edit, @item
      raise FeatureDisabled unless @features[:edit]


      respond_to do |format|
        if @item.update_attributes( allowed_params )
          format.html { redirect_to url_for( :action => @features[:show] ? 'show' : 'index', :id => @item.id ) }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    def confirm_destroy
      @item = current_object_class.find(params[:id])
      authorize! :destroy, @item
      raise FeatureDisabled unless @features[:destroy]
    end

    def destroy
      @item = current_object_class.find(params[:id])
      authorize! :destroy, @item
      raise FeatureDisabled unless @features[:destroy]
      @item.destroy

      respond_to do |format|
        format.html { redirect_to url_for( :action => 'index' ) }
      end
    end






    # Helper methods ##############################################################################


    def list_action
      if !cookies['base_module:list_action'].blank?
        feature = cookies['base_module:list_action']
        if feature == 'confirm_destroy'
          feature = 'destroy'
        end
        feature = feature.to_sym
        if @features[feature]
          return cookies['base_module:list_action']
        end
      end

      return 'show' if @features[:show]
      return 'edit'
    end

    def fields_to_display
      cols = current_object_class.column_names - %w[id created_at updated_at encrypted_password position]
      unless %w[new edit update create].include? params[:action].to_s
        cols -= %w[password password_confirmation]
      end
      return cols
    end


    def secondary_panel
      return '' unless @panel_layout
      @_secondary_panel ||= render_to_string( :partial => "secondary_panel", :layout => false, :locals => build_secondary_panel_variables)
    end

    def build_secondary_panel_variables
      menu_item_name = self.class.name.underscore.sub(/_controller$/, '')

      # if this item is defined in main menu, then there will be no altmenu
      # defined for it in alt menu, instead this method should be overriden in
      # particular controller to return structure needed to render alt menu
      return {} if Releaf.main_menu.include? menu_item_name

      # if this item was not found in main menu, then we need to find it in one
      # of alt menus. This way we'll know which alt menu to render.
      base_menus = Releaf.main_menu.reject { |item| item[0] != '*' }
      base_menus.each do |base_menu_name|
        if view_context.base_menu_items(base_menu_name).include?(menu_item_name)
          build_menu = { :menu => {} }

          base_menu = Releaf.base_menu[base_menu_name]

          base_menu.each do |section|
            section_name = section[0].to_sym
            build_menu[:menu][section_name] = []
            section[1].each do |item|
              build_menu[:menu][section_name].push({:controller => item.split(/#/, 2).first})
            end
          end

          return build_menu
        end
      end

      # coundn't find current controller in base_menu
      return {}
    end

    def current_object_class
      @_current_object_class ||= self.class.name.split('::').last.sub(/\s?Controller$/, '').classify.constantize
    end


    def has_template? name
      lookup_context.template_exists?( name, lookup_context.prefixes, false )
    end

    def find_parent_template( name )
      lookup_context.find_template( name, lookup_context.prefixes.slice( 1, lookup_context.prefixes.length ), false )
    end

    def render_parent_template( name, locals = {} )
      template = find_parent_template( name )
      if template.blank?
        return 'blank'
      end
      arguments = { :layout => false, :locals => locals, :template => template.virtual_path }
      return render_to_string( arguments ).html_safe
    end

    # Returns array with 2 items: string and boolean
    # first element of array is field_type (for rendering)
    # if seconnd argument is true template with localization should be used
    def render_field_type( obj, attribute_name )
      field_type = nil
      use_i18n = false
      obj_class = obj.class

      if obj_class.respond_to?(:translations_table_name)
        use_i18n = obj_class.translates.include?(attribute_name.to_sym)
      end

      column_type = :string
      if attribute_name.to_s =~ /^#{Releaf::Node::COMMON_FIELD_NAME_PREFIX}/
        column_type = f.object.common_field_field_type(name)
      else
        column_type = obj_class.columns_hash[attribute_name.to_s].try(:type) || :string
      end

      case column_type.to_sym
      when :boolean
        field_type = 'boolean'

      when :string
        case attribute_name.to_s
        when /(thumbnail|image|photo|picture|avatar|logo|icon)_uid$/
          field_type = 'image'

        when /_uid$/
          field_type = 'file'

        when /password/, 'pin'
          field_type = 'password'

        when /_email$/, 'email'
          field_type = 'email'

        when /_link$/, 'link'
          field_type = 'link'

        else
          field_type = 'text'
        end

      when :integer
        if attribute_name.to_s =~ /_id$/ and obj_class.reflect_on_association( attribute_name[0..-4].to_sym )
          field_type = 'item'
        else
          field_type = 'text'
        end

      when :text
        case attribute_name.to_s
        when /_(url|homepage)$/, 'homepage', 'url'
          field_type = 'url'

        when /_link$/, 'url'
          field_type = 'link_or_url'

        when /_html$/, 'html'
          field_type = 'richtext'

        else
          field_type = 'textarea'
        end

      when :datetime
        field_type = 'datetime'

      when :date
        field_type = 'date'

      when :time
        field_type = 'time'

      end

      return [field_type || 'text', use_i18n]
    end


    protected

    # Called before each request by before_filter.
    # It sets various instance variables, that are later used in views and # controllers
    #
    # == Defines
    # @fetures::
    #   Hash with symbol keys and boolean values. Each key represents action
    #   (currently only `:edit`, `:create`, `:show`, `:destroy` are supported). If one
    #   of features is disabled, then routing to it will raise <tt>Releaf::FeatureDisabled</tt>
    #   error
    #
    # @continuous_scroll::
    #   Boolean. If set to `true` will enable continuous scrool in `#index` view
    #
    # @items_per_page::
    #   Integer - sets the number of items to display on `#index` view
    #
    # To change controller settings `setup` method should be overriden like this
    #
    #   def setup
    #     super
    #     @fetures[:show] = false
    #     @items_per_page = 20
    #   end
    #
    def setup
      @features = {
        :edit     => true,
        :create   => true,
        :show     => true,
        :destroy  => true
      }
      @continuous_scroll = false
      @panel_layout      = true
      @items_per_page    = 40
    end

    def allowed_params view=params[:action]
      if self.respond_to?(:item_params)
        variables = params.require( :item ).permit( *self.send(:item_params, view) )
      elsif @item.respond_to? :allowed_params
        variables = params.require( :item ).permit( *@item.allowed_params( view ) )
      else
        variables = params.require( :item ).permit( *current_object_class.column_names )
      end
    end

    private

    def relations_for_includes
      rels = []
      fields_to_display.each do |field|
        if (field.is_a? String or field.is_a? Symbol) and field =~ /_id$/
          rels.push field[0..-4] if current_object_class.reflect_on_association(field[0..-4].to_sym)
        elsif field.is_a? Hash
          field.keys.each do |key|
            if key =~ /_id$/
              rels.push key[0..-4] if current_object_class.reflect_on_association(key[0..-4].to_sym)
            else
              rels.push key if current_object_class.reflect_on_association(key.to_sym)
            end
          end
        end
      end
      return rels
    end

    def valid_order_by
      return nil if params[:order_by].blank?
      return nil unless current_object_class.column_names.include?(params[:order_by].sub(/-reverse$/, ''))
      return current_object_class.table_name + '.' + params[:order_by].sub(/-reverse$/, ' DESC')
    end

    def set_locale
      I18n.locale = if params[:locale] && Settings.i18n_locales.include?(params[:locale])
        params[:locale]
      elsif cookies[:locale] && Settings.i18n_locales.include?(cookies[:locale])
        cookies[:locale]
      else
        I18n.default_locale
      end

      Releaf::Globalize3::Fallbacks.set
    end

    def filter_templates
      filter_templates_from_hash params
    end

    def filter_templates_from_array arr
      return unless arr.is_a? Array
      arr.each do |item|
        if item.is_a? Hash
          filter_templates_from_hash item
        elsif item.is_a? Array
          filter_templates_from_array item
        end
      end
    end

    def filter_templates_from_hash hsk
      return unless hsk.is_a? Hash
      hsk.delete :_template_
      hsk.delete '_template_'

      filter_templates_from_array hsk.values
    end

  end
end
