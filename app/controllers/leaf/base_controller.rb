module Leaf
  class BaseController < BaseApplicationController
    before_filter do
      filter_templates
      set_locale
      setup
    end

    def setup
      @controller        = self # this is used later in views
      @features          = { :create => true, :show => true, :edit => true, :destroy => true}
      @panel_layout      = true
      @continuous_scroll = false
      @items_per_page    = 40
    end

    def secondary_panel
      return '' unless @panel_layout
      @_secondary_panel ||= render_to_string( :partial => "secondary_panel", :layout => false, :locals => build_secondary_panel_variables)
    end

    def build_secondary_panel_variables
      {}
    end

    def build_secondary_panel_variables_first_item_url
      return {:action => :index, :controller => :content} if build_secondary_panel_variables[:menu].blank?
      build_secondary_panel_variables[:menu].each_pair do |k,v|
        if v.is_a? Array
          return v.first
        end
      end
    end

    def current_object_class
      @_current_object_class ||= self.class.name.sub(/^.*::/, '').sub(/\s?Controller$/, '').classify.constantize
    end

    def current_object_class_name
      current_object_class.name.underscore.tr('/', '_')
    end

    def columns( view = nil )
      cols = current_object_class.column_names - %w[id created_at updated_at encrypted_password]
      unless %w[new edit update create].include? view
        cols -= %w[password password_confirmation]
      end
      return cols
    end

    def list_action
      if !cookies['base_module:list_action'].blank?
        feature = cookies['base_module:list_action']
        if feature == 'confirm_destroy'
          feature = 'destroy'
        end
        feature = feature.to_sym
        if !@features[ feature ].blank?
          return cookies['base_module:list_action']
        end
      end
      if !@features[ :show ].blank?
        return 'show'
      end
      return 'edit';
    end

    def has_template( name )
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

    def input_type_for( column_type, name )
      input_type = 'text'
      case column_type
      when :boolean
        input_type = 'checkbox'
      when :text
        input_type = 'textarea'
        if name.end_with?( '_html' )
          input_type = 'richtext'
        end
      end
      return input_type
    end

    # actions

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
      if current_object_class.respond_to?( :filter )
        @list = current_object_class.filter(:search => params[:search])
      else
        @list = current_object_class
      end
      @list = @list.page( params[:page] ).per_page( @items_per_page )
      if !params[:ajax].blank?
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
      @item = current_object_class.new
    end

    def show
      @item = current_object_class.find(params[:id])
      authorize! :show, @item
    end

    def edit
      @item = current_object_class.find(params[:id])
      authorize! :edit, @item
    end

    def create
      authorize! :create, current_object_class
      @item = current_object_class.new

      if @item.respond_to? :allowed_params
        variables = params.require( current_object_class_name ).permit( *@item.allowed_params(:create) )
      else
        variables = params.require( current_object_class_name ).permit( *current_object_class.column_names )
      end

      @item.assign_attributes( variables )

      respond_to do |format|
        if @item.save
          format.html { redirect_to url_for( :action => 'show', :id => @item.id ) }
        else
          format.html { render :action => "new" }
        end
      end
    end

    def update
      @item = current_object_class.find(params[:id])
      authorize! :edit, @item

      if self.respond_to?(:"#{current_object_class_name}_params")
        variables = params.require( current_object_class_name ).permit( *self.send(:"#{current_object_class_name}_params", :update) )
      elsif @item.respond_to? :allowed_params
        variables = params.require( current_object_class_name ).permit( *@item.allowed_params(:update) )
      else
        variables = params.require( current_object_class_name ).permit( *current_object_class.column_names )
      end


      respond_to do |format|
        if @item.update_attributes( variables )
          format.html { redirect_to url_for( :action => 'show', :id => @item.id ) }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    def confirm_destroy
      @item = current_object_class.find(params[:id])
      authorize! :destroy, @item
    end

    def destroy
      @item = current_object_class.find(params[:id])
      authorize! :destroy, @item
      @item.destroy

      respond_to do |format|
        format.html { redirect_to url_for( :action => 'index' ) }
      end
    end


    private

    def set_locale
      I18n.locale = if params[:locale] && Settings.i18n_locales.include?(params[:locale])
        params[:locale]
      elsif cookies[:locale] && Settings.i18n_locales.include?(cookies[:locale])
        cookies[:locale]
      else
        I18n.default_locale
      end
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
