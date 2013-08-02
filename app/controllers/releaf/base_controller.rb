module Releaf
  class FeatureDisabled < StandardError; end

  class BaseController < BaseApplicationController
    helper_method \
      :fields_to_display,
      :find_parent_template,
      :get_template_field_attributes,
      :get_template_input_attributes,
      :get_template_label_options,
      :input_locales,
      :has_template?,
      :render_field_type,
      :render_parent_template,
      :resource_class,
      :resource_to_text,
      :resource_to_text_method

    before_filter do
      authorize!
      filter_templates
      setup
    end

    def autocomplete
      c_obj = resource_class

      if params[:query_field] && params[:q] && params[:field]
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
      raise FeatureDisabled unless @features[:index]
      @resources = filter_order_and_paginate_collection(get_collection)

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
      raise FeatureDisabled unless @features[:create]
      @resource = resource_class.new
    end

    def show
      redirect_to url_for( :action => 'edit', :id => params[:id])
    end

    def edit
      raise FeatureDisabled unless @features[:edit]
      # load resource only if is not loaded yet
      @resource = resource_class.includes(relations_for_includes).find(params[:id]) if @resource.nil?
    end

    def validate
      if params[:id].nil?
        # load resource only if is not loaded yet
        @resource = resource_class.new
      else
        # load resource only if is not loaded yet
        @resource = resource_class.includes(relations_for_includes).find(params[:id]) if @resource.nil?
      end

      @resource.assign_attributes required_params.permit(*resource_params)

      if @resource.valid?
        render :json => {}
      else
        render :json => build_validation_errors(@resource), :status => 422
      end
    end

    def create
      raise FeatureDisabled unless @features[:create]
      save_and_respond :create
    end

    def update
      raise FeatureDisabled unless @features[:edit]
      save_and_respond :update
    end

    def confirm_destroy
      raise FeatureDisabled unless @features[:destroy]
      @resource = resource_class.find(params[:id])
      render :layout => false if params.has_key?(:ajax)
    end

    def destroy
      raise FeatureDisabled unless @features[:destroy]
      @resource = resource_class.find(params[:id])
      result = @resource.destroy

      if result
        flash[:success] = { :id => :resource_status, :message => I18n.t('deleted', :scope => 'notices.' + controller_scope_name) }
      end

      respond_to do |format|
        format.html { redirect_to url_for( :action => 'index' ) }
      end
    end

    # Helper methods ##############################################################################


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
      cols = resource_class.column_names - %w[id created_at updated_at encrypted_password item_position]

      if resource_class.respond_to?(:translations_table_name)
        cols += resource_class.translates.map { |a| a.to_s }
      end

      unless %w[new edit update create].include? params[:action]
        cols -= %w[password password_confirmation]
      end

      return cols
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

    # Helps to determinate which template to render in :edit feature
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

      column_type = :VIRTUAL

      if obj_class.respond_to?(:translations_table_name)
        use_i18n = obj_class.translates.include?(attribute_name.to_sym)
      end

      if use_i18n
        begin
          column_type = obj_class::Translation.columns_hash[attribute_name.to_s].try(:type) || :VIRTUAL
        rescue
        end
      else
        column_type = obj_class.columns_hash[attribute_name.to_s].try(:type) || :VIRTUAL
      end

      if column_type == :VIRTUAL
        if attribute_name.to_s =~ /^#{Releaf::Node::COMMON_FIELD_NAME_PREFIX}/
          column_type = obj.common_field_field_type(attribute_name)
        end
      end

      case column_type.to_sym
      when :boolean
        field_type = 'boolean'

      when :string
        case attribute_name.to_s
        when /(thumbnail|image|photo|picture|avatar|logo|banner|icon)_uid$/
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
        if attribute_name.to_s =~ /_id$/ && obj_class.reflect_on_association(attribute_name[0..-4].to_sym)
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
      else # virtual attributes
        case attribute_name.to_s
        when /(thumbnail|image|photo|picture|avatar|logo|banner|icon)_uid$/
          field_type = 'image'

        when /_id$/
          if obj_class.reflect_on_association(attribute_name[0..-4].to_sym)
            field_type = 'item'
          else
            field_type = 'text'
          end

        when /_uid$/
          field_type = 'file'

        when /password/, 'pin'
          field_type = 'password'

        when /_email$/, 'email'
          field_type = 'email'

        when /_link$/, 'link'
          field_type = 'link'

        when /_(url|homepage)$/, 'homepage', 'url'
          field_type = 'url'

        when /_link$/, 'url'
          field_type = 'link_or_url'

        when /_text$/, /_description$/, 'text', 'description'
          field_type = 'textarea'

        when /_html$/, 'html'
          field_type = 'richtext'

        when /_date$/, 'date', /_on$/
          field_type = 'date'

        when /_time$/, 'time'
          field_type = 'time'

        when /_at$/
          field_type = 'datetime'
        else
          field_type = 'text'
        end
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

    # This helper will return options passed to render 'edit_label'.
    # It will merge in label_options when present
    def get_template_label_options local_assigns, options={}
      raise ArgumentError unless options.is_a? Hash
      default_options = {
        :f => local_assigns.fetch(:f, nil),
        :name => local_assigns.fetch(:name, nil)
      }.deep_merge(options)

      raise RuntimeError, 'form_builder not passed to partial' if default_options[:f].blank?
      raise RuntimeError, 'name not passed to partial'         if default_options[:name].blank?

      return default_options unless local_assigns.key? :label_options

      custom_options = local_assigns[:label_options]
      raise RuntimeError, 'label_options must be a Hash' unless custom_options.is_a? Hash
      return default_options.deep_merge(custom_options)
    end

    # This helper will return attributes for input fields (input, select,
    # textarea). It will merge in input_attributes when present. You can pass
    # any valid html attributes to input_attributes
    def get_template_input_attributes local_assigns, attributes={}
      raise ArgumentError unless attributes.is_a? Hash
      default_attributes = attributes
      return default_attributes unless local_assigns.key? :input_attributes

      custom_attributes = local_assigns[:input_attributes]
      raise RuntimeError, 'input_attributes must be a Hash' unless custom_attributes.is_a? Hash
      return default_attributes.deep_merge(custom_attributes)
    end

    # This helper will return attributes for fields.  It will merge in
    # field_attributes when present. You can pass any valid html attributes to
    # field_attributes
    def get_template_field_attributes local_assigns, attributes={}
      raise ArgumentError unless attributes.is_a? Hash
      default_attributes = {
        :data => {
          :name => local_assigns.fetch(:name, nil)
        }
      }.deep_merge(attributes)

      raise RuntimeError, 'name not passed to partial' if default_attributes[:data].try('[]', :name).blank?

      return default_attributes unless local_assigns.key? :field_attributes

      custom_attributes = local_assigns[:field_attributes]
      raise RuntimeError, 'field_attributes must be a Hash' unless custom_attributes.is_a? Hash
      return default_attributes.deep_merge(custom_attributes)
    end

    protected

    def authorize! action=nil
      user = self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}")
      raise Releaf::AccessDenied.new(controller_name, action) unless user.role.authorize!(self, action)
    end

    # Get resources collection for #index
    def get_collection
      resource_class
    end

    # filter, order and paginate resources
    def filter_order_and_paginate_collection resources
      scoped_resources = resources

      if resource_class.respond_to? :filter
        scoped_resources = scoped_resources.filter(params)
      end

      if resource_class.respond_to? :order_by
        scoped_resources = scoped_resources.order_by(valid_order_by)
      end

      scoped_resources = scoped_resources.includes(relations_for_includes).page( params[:page] ).per_page( @resources_per_page )

      return scoped_resources
    end

    def required_params
      params.require(:resource)
    end

    # Called before each request by before_filter.
    # It sets various instance variables, that are later used in views and # controllers
    #
    # == Defines
    # @fetures::
    #   Hash with symbol keys and boolean values. Each key represents action
    #   (currently only `:edit`, `:create`, `:destroy` are supported). If one
    #   of features is disabled, then routing to it will raise <tt>Releaf::FeatureDisabled</tt>
    #   error
    #
    # @resources_per_page::
    #   Integer - sets the number of resources to display on `#index` view
    #
    # To change controller settings `setup` method should be overriden like this
    #
    # @example
    #   def setup
    #     super
    #     @fetures[:edit] = false
    #     @resources_per_page = 20
    #   end

    def setup
      @features = {
        :edit     => true,
        :edit_ajax_reload  => true,
        :create   => true,
        :destroy  => true,
        :index    => true,
        # enable toolbox for each table row
        # it can be unnecessary for read only report like indexes
        :index_row_toolbox   => true,
        # enable text search field if class responds to filter scope
        # some classes may respond to filter but have no textual search
        :index_text_search   => true
      }
      @panel_layout      = true
      @resources_per_page    = 40
    end

    def mass_assigment_actions
      ['create', 'update', 'validate']
    end

    # Returns which resource attributes can be updated with mass assignment.
    #
    # The resulting array will be passed to strong_parameters ``permit``
    def resource_params
      return unless mass_assigment_actions.include? params[:action]

      cols = resource_class.column_names.dup
      if resource_class.respond_to?(:translations_table_name)
        cols = cols + localize_attributes(resource_class.translates)
      end

      return cols
    end

    def localize_attributes args
      attributes = []
      if args.is_a? Array
        args.each do |attribute|
          resource_class.available_input_locales.each do|locale|
            attributes << "#{attribute}_#{locale}"
          end
        end
      end

      return attributes
    end

    # Tries to automagically figure you which relations should be passed to
    # .includes
    def relations_for_includes
      rels = []
      rels.push :translations if resource_class.respond_to?(:translations_table_name)

      fields_to_display.each do |field|
        if (field.is_a?(String) || field.is_a?(Symbol)) && field =~ /_id$/
          reflection_name = field[0..-4].to_sym
        elsif field.is_a? Hash
          field.keys.each do |key|
            if key =~ /_id$/
              reflection_name = key[0..-4].to_sym
            else
              reflection_name = key.to_sym
            end
          end
        end

        next if reflection_name.blank?

        reflection = resource_class.reflect_on_association(reflection_name)
        next if reflection.blank?

        # things break with polyporhic associations
        next if reflection.options[:polymorphic]

        relation_class = reflection.klass
        if relation_class.respond_to? :translations_table_name
          rels.push({ reflection_name.to_s => :translations })
        else
          rels.push reflection_name.to_s
        end
      end

      return rels
    end

    # Returns valid order sql statement.
    #
    # This function is used if resource class supports .order_by scope.
    def valid_order_by
      return nil if params[:order_by].blank?
      return nil unless resource_class.column_names.include?(params[:order_by].sub(/-reverse$/, ''))
      return resource_class.table_name + '.' + params[:order_by].sub(/-reverse$/, ' DESC')
    end

    private

    def save_and_respond request_type
      if request_type == :create
        # load resource only if is not loaded yet
        @resource = resource_class.new if @resource.nil?
        @resource.assign_attributes required_params.permit(*resource_params)
        result = @resource.save

        html_render_action = "new"
      elsif request_type == :update
        # load resource only if is not loaded yet
        @resource = resource_class.find(params[:id]) if @resource.nil?
        result = @resource.update_attributes required_params.permit(*resource_params)

        html_render_action = "edit"
      end

      respond_after_save request_type, result, html_render_action
    end

    def respond_after_save request_type, result, html_render_action

      if result
        if request_type == :create
          flash[:success] = { :id => :resource_status, :message => I18n.t('created', :scope => 'notices.' + controller_scope_name) }
        else
          flash[:success] = { :id => :resource_status, :message => I18n.t('updated', :scope => 'notices.' + controller_scope_name) }
        end

        success_url = url_for( :action => 'edit', :id => @resource.id )
      end

      respond_to do |format|
        format.json  do
          if result
            if @features[:edit_ajax_reload] && request_type == :update
              flash.discard(:success)
              flash.now[:success] = { :id => :resource_status, :message => I18n.t('updated', :scope => 'notices.' + controller_scope_name) }
              render :action => html_render_action, :formats => [:html], :content_type => "text/html"
            else
              render :json => {:url => success_url, :message => flash[:success][:message]}, :status => 303
            end
          else
            render :json => build_validation_errors(@resource), :status => 422
          end
        end

        format.html do
          if result
            redirect_to success_url
          else
            flash[:error] = { :id => :resource_status, :message => I18n.t('error', :scope => 'notices.' + controller_scope_name) }
            render :action => html_render_action
          end
        end
      end

    end



    def build_validation_errors resource
      errors = {}
      resource.errors.each do |attribute, message|
        field_id = validation_attribute_field_id resource, attribute
        unless errors.has_key? attribute
          errors[field_id] = []
        end

        errors[field_id] << {:error => message, :full_message => I18n.t(message, :scope => 'validation.' + controller_scope_name)}
      end

      return errors
    end

    def validation_attribute_field_id resource, attribute
      parts = attribute.to_s.split('.')
      prefix = "resource"

      if parts.length > 1
        field_name = validation_attribute_nested_field_name(resource, parts)
      else
        field_name = "["
        field_name += parts[0]
        # normalize field id for globalize3 attributes without prefix
        if resource_class.respond_to?(:translations_table_name) && resource_class.translates.include?(attribute.to_sym)
          field_name += "_#{I18n.default_locale}"
        end

        field_name += "]"
      end

      field_name = prefix + field_name

      return field_name
    end

    def validation_attribute_nested_field_name resource, parts
      index = 0
      resource.send(parts[0]).each do |item|
        unless item.valid?
          field_id = "[" + parts[0] + "_attributes][#{index}]"
          if parts.length == 2
            field_id += "[" + parts[1] + "]"
          else
            field_id += validation_attribute_nested_field_name(item, parts[1..-1])
          end

          return field_id
        end

        index += 1
      end
    end

    def filter_templates
      filter_templates_from_hash(params)
    end

    def filter_templates_from_array arr
      return unless arr.is_a? Array
      arr.each do |item|
        if item.is_a? Hash
          filter_templates_from_hash(item)
        elsif item.is_a? Array
          filter_templates_from_array(item)
        end
      end
    end

    def filter_templates_from_hash hsk
      return unless hsk.is_a? Hash
      hsk.delete :_template_
      hsk.delete '_template_'

      filter_templates_from_array(hsk.values)
    end
  end
end
