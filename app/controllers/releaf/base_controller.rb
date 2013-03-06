module Releaf
  class FeatureDisabled < StandardError; end

  class BaseController < BaseApplicationController
    helper_method :build_secondary_panel_variables,
      :fields_to_display,
      :resource_class,
      :find_parent_template,
      :has_template?,
      :list_action,
      :render_field_type,
      :render_parent_template,
      :secondary_panel,
      :current_feature,
      :resource_to_text,
      :resource_to_text_method

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
      authorize! :edit, resource_class

      c_obj = resource_class

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

        @resources = []
        list.each do |resource|
          @resources.push({ :id => resource.id, :text => resource.to_text })
        end

        respond_to do |format|
          format.json { render :json => {:matching_items_count => matching_items_count, :query => params[:q], :results => @resources } }
        end

      else
        respond_to do |format|
          format.json { raise }
        end
      end
    end

    def index
      authorize! :list, resource_class
      if resource_class.respond_to? :filter
        @resources = resource_class.filter(:search => params[:search])
      else
        @resources = resource_class
      end

      if resource_class.respond_to? :order_by
        @resources = @resources.order_by(valid_order_by)
      end

      @resources = @resources.includes(relations_for_includes).page( params[:page] ).per_page( @resources_per_page )

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
      authorize! :create, resource_class
      raise FeatureDisabled unless @features[:create]
      @resource = resource_class.new
    end

    def show
      @resource = resource_class.includes(relations_for_includes).find(params[:id])
      authorize! :show, @resource
      raise FeatureDisabled unless @features[:show]
    end

    def edit
      @resource = resource_class.includes(relations_for_includes).find(params[:id])
      authorize! :edit, @resource
      raise FeatureDisabled unless @features[:edit]
    end

    def create
      authorize! :create, resource_class
      raise FeatureDisabled unless @features[:create]

      @resource = resource_class.new

      @resource.assign_attributes params.require(:resource).permit(*resource_params)

      respond_to do |format|
        if @resource.save
          format.html { redirect_to url_for( :action => @features[:show] ? 'show' : 'index', :id => @resource.id ) }
        else
          format.html { render :action => "new" }
        end
      end
    end

    def update
      @resource = resource_class.find(params[:id])
      authorize! :edit, @resource
      raise FeatureDisabled unless @features[:edit]

      respond_to do |format|
        if @resource.update_attributes( params.require(:resource).permit(*resource_params) )
          format.html { redirect_to url_for( :action => @features[:show] ? 'show' : 'index', :id => @resource.id ) }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    def confirm_destroy
      @resource = resource_class.find(params[:id])
      authorize! :destroy, @resource
      raise FeatureDisabled unless @features[:destroy]
    end

    def destroy
      @resource = resource_class.find(params[:id])
      authorize! :destroy, @resource
      raise FeatureDisabled unless @features[:destroy]
      @resource.destroy

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

    # Defines which fields/associations should be rendered.
    #
    # By default renders resource columns except few (check source).
    #
    # You can override this method to make it possible to render pretty complex
    # views which inludes nested fields.
    #
    # To render field you simply need to add it's name to array.
    #
    # belongs_to relations will be automatically rendered (by default) as
    # select field.  For belongs_to to be recognized you need to use Integer
    # field that ends with <tt>_id</tt>
    #
    # You can also render has_many associations. For these associations you
    # need to add either association name, or a Hash. Hash keys must match
    # association name, hash value must be array with nested fields to be
    # rendered.
    #
    # NOTE: currently if you add has_many associations name to array, then it
    # will render all fields (except created_at etc.) including <tt>belongs_to
    # :parent</tt>. This is know bug https://github.com/cubesystems/releaf/issues/64
    #
    # @example
    #   def fields_to_display
    #     case params[:action]
    #     when 'edit', 'update', 'create', 'new'
    #       return [
    #         'name',
    #         'category_id',
    #         'description',
    #         {'offer_card_types' => ['card_type_id', 'name', 'description']},
    #         'show_banner',
    #         'published',
    #         'item_count',
    #         {'images' => ['image_uid']},
    #         'partner_id',
    #         'offer_checkout_places' => ['checkout_place_id']
    #       ]
    #     else
    #       return super
    #     end
    #   end
    #
    # Fields will be rendered in same order as specified in array
    #
    # @return array that represent which fields to render
    def fields_to_display
      cols = resource_class.column_names - %w[id created_at updated_at encrypted_password position]
      unless %w[new edit update create].include? params[:action]
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

    # Tries to return resource class.
    #
    # If it fails to return proper resource class for your controller, or your
    # controllers name has no relation to resource class name, then simply
    # override this method to return class that you want.
    #
    # @return class
    def resource_class
      @resource_class ||= self.class.name.split('::').last.sub(/Controller$/, '').classify.constantize
    end


    # Cheheck if there is a template in lookup_context with given name.
    #
    # @return `true` or `false`
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

    # Helps to determinate which template to render in :show and :edit feature
    # for given objects attribute.
    #
    # @return [field_type, use_i18n]
    #
    # where field_type is a string representing field type
    # and use_i18n is a `true` or `false`. If use_i18n is true, then template
    # with localization features should be used (if exists)
    #
    # This helper is used by views.
    #
    # @todo document rendering conventions
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

    # calls `#to_text` on resource if resource supports it. Otherwise calls
    # fallback method
    def resource_to_text resource, fallback=:to_s
      resource.send resource_to_text_method(resource, fallback)
    end

    # @return `:to_text` if resource supports `#to_text`, otherwise fallback.
    def resource_to_text_method resource, fallback=:to_s
      if resource.respond_to?(:to_text)
        return :to_text
      else
        Rails.logger.warn "Re:Leaf: #{resource.class.name} doesn't support #to_text method. Please define it"
        return fallback
      end
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
    # @resources_per_page::
    #   Integer - sets the number of resources to display on `#index` view
    #
    # To change controller settings `setup` method should be overriden like this
    #
    # @example
    #   def setup
    #     super
    #     @fetures[:show] = false
    #     @resources_per_page = 20
    #   end
    def setup
      @features = {
        :edit     => true,
        :create   => true,
        :show     => true,
        :destroy  => true
      }
      @continuous_scroll = false
      @panel_layout      = true
      @resources_per_page    = 40
    end

    # Returns which resource attributes can be updated with mass assignment.
    #
    # The resulting array will be passed to strong_parameters ``permit``
    def resource_params
      return unless %w[create update].include? params[:action]
      resource_class.column_names
    end

    private

    def relations_for_includes
      # XXX there's a problem with relations that have conditions with proc.
      # If you refer to models attribute in proc, this function will break.
      # As temp workaround we'll simply skip including relations that have conditions for now.
      rels = []
      fields_to_display.each do |field|
        if (field.is_a? String or field.is_a? Symbol) and field =~ /_id$/
          reflection = resource_class.reflect_on_association(field[0..-4].to_sym)
          next if reflection.blank?
          next unless reflection.conditions.blank?
          rels.push field[0..-4]
        elsif field.is_a? Hash
          field.keys.each do |key|
            if key =~ /_id$/
              reflection = resource_class.reflect_on_association(key[0..-4].to_sym)
              next if reflection.blank?
              next unless reflection.conditions.blank?
              rels.push key[0..-4] if resource_class.reflect_on_association(key[0..-4].to_sym)
            else
              reflection = resource_class.reflect_on_association(key.to_sym)
              next if reflection.blank?
              next unless reflection.conditions.blank?
              rels.push key if resource_class.reflect_on_association(key.to_sym)
            end
          end
        end
      end
      return rels
    end

    def valid_order_by
      return nil if params[:order_by].blank?
      return nil unless resource_class.column_names.include?(params[:order_by].sub(/-reverse$/, ''))
      return resource_class.table_name + '.' + params[:order_by].sub(/-reverse$/, ' DESC')
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
