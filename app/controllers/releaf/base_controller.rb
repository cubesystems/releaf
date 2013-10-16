module Releaf
  class FeatureDisabled < StandardError; end

  class BaseController < BaseApplicationController
    helper_method \
      :fields_to_display,
      :find_parent_template,
      :get_template_field_attributes,
      :get_template_input_attributes,
      :get_template_label_options,
      :has_template?,
      :render_field_type,
      :render_parent_template,
      :resource_class,
      :resource_to_text,
      :resource_to_text_method,
      :attachment_upload_url

    before_filter do
      authorize!
      filter_templates
      build_breadcrumbs
      setup
    end

    def new_attachment
      render :layout => nil
    end

    def create_attachment
      @resource = Attachment.new
      if params[:file]
        @resource.file_type = params[:file].content_type
        @resource.file  = params[:file]
        @resource.title = params[:title] if params[:title].present?
        @resource.save!

        partial = case @resource.type
                  when 'image' then 'image'
                  else
                    'link'
                  end
        render :partial => "attachment_#{partial}", :layout => nil
      else
        render :text => ''
      end
    end

    def index &block
      check_feature(:index)
      # load resource only if they are not loaded yet
      @resources = collection if @resources.nil?

      if @searchable_fields && !params[:search].blank?
        search(params[:search])
      end

      @resources = @resources.page( params[:page] ).per_page( @resources_per_page )
      yield if block_given?

      unless params[:ajax].blank?
        render layout: false
      end
    end

    def new &block
      check_feature(:create)
      # load resource only if is not initialized yet
      @resource = resource_class.new if @resource.nil?
      add_resource_breadcrumb(@resource)
      yield if block_given?
    end

    def show &block
      yield if block_given?
      redirect_to url_for( action: 'edit', id: params[:id])
    end

    def edit &block
      check_feature(:edit)
      # load resource only if is not loaded yet
      @resource = resource_class.find(params[:id]) if @resource.nil?
      add_resource_breadcrumb(@resource)
      yield if block_given?
    end

    def create &block
      check_feature(:create)
      # load resource only if is not loaded yet
      @resource = resource_class.new if @resource.nil?
      @resource.assign_attributes required_params.permit(*resource_params)
      result = @resource.save

      respond_after_save(:create, result, "new", &block)
    end

    def update &block
      check_feature(:edit)
      # load resource only if is not loaded yet
      @resource = resource_class.find(params[:id]) if @resource.nil?
      result = @resource.update_attributes required_params.permit(*resource_params)

      respond_after_save(:update, result, "edit", &block)
    end

    def confirm_destroy
      check_feature(:destroy)
      @resource = resource_class.find(params[:id])

      if destroyable?
        render layout: false if params.has_key?(:ajax)
      else
        @restrict_relations = list_restrict_relations
        render 'delete_restricted', layout: !params.has_key?(:ajax)
      end
    end

    def destroy
      check_feature(:destroy)
      @resource = resource_class.find(params[:id])
      if destroyable?
        result = @resource.destroy

        if result
          flash[:success] = { id: :resource_status, message: I18n.t('deleted', scope: 'notices.' + controller_scope_name) }
        end
      else
        flash[:error] = { id: :resource_status, message: I18n.t('cant destroy, because relations exists', scope: 'notices.' + controller_scope_name) }
      end

      respond_to do |format|
        redirect_url = params[:list_url]
        redirect_url = url_for( action: 'index') if redirect_url.nil?

        format.html { redirect_to redirect_url }
      end
    end

    # Check if @resource has existing restrict relation and it can be deleted
    #
    # @returns boolean true or false
    def destroyable?
      resource_class.reflect_on_all_associations.all? do |assoc|
        assoc.options[:dependent] != :restrict ||
          !@resource.send(assoc.name).exists?
      end
    end


    # Lists relations for @resource with dependent: :restrict
    #
    # @returns hash of all related objects, who have dependancy :restrict
    def list_restrict_relations
      relations = {}
      resource_class.reflect_on_all_associations.each do |assoc|
        if assoc.options[:dependent] == :restrict && @resource.send(assoc.name).exists?
          relations[assoc.name.to_sym] = {
            objects:    @resource.send(assoc.name),
            controller: association_controller(assoc)
          }
        end
      end

      return relations
    end

    # Attempts to guess associated controllers name
    #
    # @returns controller name
    def association_controller association
      guessed_name = association.name.to_s.pluralize
      return guessed_name unless Releaf.controller_list.values.map{ |v| v[:controller] }.grep(/(\/#{guessed_name}$|^#{guessed_name}$)/).blank?
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
    #
    #   end
    #
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

    def attachment_upload_url
      url_for(:action => 'new_attachment')
    rescue
      ''
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

      arguments = { layout: false, locals: locals, template: template.virtual_path }
      return render_to_string( arguments ).html_safe
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
        f: local_assigns.fetch(:f, nil),
        name: local_assigns.fetch(:name, nil),
        attributes: {}
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
        data: {
          name: local_assigns.fetch(:name, nil)
        }
      }.deep_merge(attributes)

      raise RuntimeError, 'name not passed to partial' if default_attributes[:data].try('[]', :name).blank?

      return default_attributes unless local_assigns.key? :field_attributes

      custom_attributes = local_assigns[:field_attributes]
      raise RuntimeError, 'field_attributes must be a Hash' unless custom_attributes.is_a? Hash
      return default_attributes.deep_merge(custom_attributes)
    end

    protected

    # Return ActiveRecord::Base or ActiveRecord::Relation used in index
    #
    # @return ActiveRecord::Base or ActiveRecord::Relation
    def collection
      resource_class
    end

    def authorize! action=nil
      user = self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}")
      raise Releaf::AccessDenied.new(controller_name, action) unless user.role.authorize!(self, action)
    end

    # Get resources collection for #index
    def search text
      fields = search_fields(resource_class, @searchable_fields)
      s_joins = normalized_search_joins( search_joins(resource_class, @searchable_fields) )
      @resources = @resources.includes(*s_joins)
      text.strip.split(" ").each_with_index do|word, i|
        query = fields.map { |field| "#{field} LIKE :word#{i}" }.join(' OR ')
        @resources = @resources.where(query, "word#{i}".to_sym =>'%' + word + '%')
      end
    end

    # Returns array of fields in which to search for string typed in search form
    def search_fields klass, attributes
      fields = []
      attributes.each do|attribute|
        if attribute.is_a? Symbol
          fields << "#{klass.table_name}.#{attribute.to_s}"
        elsif attribute.is_a? Hash
          attribute.each_pair do |key, values|
            association = klass.reflect_on_association(key.to_sym)
            fields += search_fields(association.klass, values)
            if association.macro == :has_many
              @resources = @resources.group("#{association.klass.table_name}.id")
            end
          end
        end
      end

      return fields
    end

    # Returns data structure for .includes or .joins that represents resource
    # associations, beased on given structure of attributes
    #
    # This helper is mainly intended for #search
    def search_joins klass, attributes
      s_joins = {}
      attributes.each do|attribute|
        if attribute.is_a? Hash
          attribute.each_pair do |key, values|
            association = klass.reflect_on_association(key.to_sym)
            s_joins[key] = s_joins.fetch(key, {}).deep_merge( search_joins(association.klass, values) )
          end
        end
      end

      return s_joins
    end

    # Normalizes #search_joins results by removing blank hashes
    def normalized_search_joins search_joins
      raise ArgumentError unless search_joins.is_a? Hash
      assoc = []
      search_joins.each_pair do |k, v|
        if v.blank?
          assoc.push k
        else
          normalized_v = normalized_search_joins v
          if normalized_v.blank?
            assoc.push k
          else
            assoc.push({k => normalized_v})
          end
        end
      end
      return assoc
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
        edit:              true,
        edit_ajax_reload:  true,
        create:            true,
        destroy:           true,
        index:             true,
        # enable toolbox for each table row
        # it can be unnecessary for read only report like indexes
        index_row_toolbox: true
      }
      @panel_layout      = true
      @resources_per_page    = 40
    end

    def mass_assigment_actions
      ['create', 'update']
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
          resource_class.globalize_locales.each do|locale|
            attributes << "#{attribute}_#{locale}"
          end
        end
      end

      return attributes
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

    def check_feature feature
      raise FeatureDisabled, feature.to_s unless @features[feature]
    end

    def respond_after_save request_type, result, html_render_action, &block
      if result
        if request_type == :create
          flash[:success] = { id: :resource_status, message: I18n.t('created', scope: 'notices.' + controller_scope_name) }
        else
          flash[:success] = { id: :resource_status, message: I18n.t('updated', scope: 'notices.' + controller_scope_name) }
        end

        yield if block_given?

        success_url = url_for( action: 'edit', id: @resource.id )
      end

      respond_to do |format|
        format.json  do
          if result
            if @features[:edit_ajax_reload] && request_type == :update
              add_resource_breadcrumb(@resource)
              flash.discard(:success)
              flash.now[:success] = { id: :resource_status, message: I18n.t('updated', scope: 'notices.' + controller_scope_name) }
              render action: html_render_action, formats: [:html], content_type: "text/html"
            else
              render json: {url: success_url, message: flash[:success][:message]}, status: 303
            end
          else
            render json: build_validation_errors(@resource), status: 422
          end
        end

        format.html do
          if result
            redirect_to success_url
          else
            flash[:error] = { id: :resource_status, message: I18n.t('error', scope: 'notices.' + controller_scope_name) }
            render action: html_render_action
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

        errors[field_id] << {error_code: message.error_code, full_message: I18n.t(message, scope: 'validation.' + controller_scope_name)}
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

      association_type = resource.class.reflect_on_association(parts[0].to_sym).macro
      if association_type == :belongs_to
        nested_items = [resource.send(parts[0])]
      else
        nested_items = resource.send(parts[0])
      end

      nested_items.each do |item|
        unless item.valid?
          if association_type == :belongs_to
            field_id = "[" + parts[0] + "_attributes][#{parts[1]}]"
          else
            field_id = "[" + parts[0] + "_attributes][#{index}]"
            if parts.length == 2
              field_id += "[" + parts[1] + "]"
            else
              field_id += validation_attribute_nested_field_name(item, parts[1..-1])
            end
          end

          return field_id
        end

        index += 1
      end
    end

    def filter_templates
      filter_templates_from_hash(params)
    end

    def build_breadcrumbs
      @breadcrumbs = []
      @breadcrumbs << { name: I18n.t('Home', scope: 'admin.breadcrumbs'), url: releaf_root_path }

      controller_params = Releaf.controller_list[self.class.name.sub(/Controller$/, '').underscore]
      unless controller_params.nil?
        @breadcrumbs << {
          name: I18n.t(controller_params[:name], scope: "admin.menu_items"),
          url: send(controller_params[:url_helper])
        }
      end
    end

    def add_resource_breadcrumb resource
      if resource.new_record?
        name=  I18n.t('New record', scope: 'admin.breadcrumbs')
        url = url_for(action: :new, only_path: true)
      else
        if resource.respond_to?(:to_text)
          name = resource.send(:to_text)
        else
          name = I18n.t('Edit record', scope: 'admin.breadcrumbs')
        end
        url = url_for(action: :edit, id: resource.id, only_path: true)
      end
      @breadcrumbs << { name: name, url: url }
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
