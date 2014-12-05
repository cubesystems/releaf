module Releaf
  class FeatureDisabled < StandardError; end

  class BaseController < ActionController::Base
    include Releaf::BeforeRender
    include Releaf::SerializedArrayParamsNormalizer

    before_filter "authenticate_#{ReleafDeviseHelper.devise_admin_model_name}!"
    before_filter :manage_ajax
    before_filter :set_locale

    before_filter do
      authorize!
      build_breadcrumbs
      setup
    end

    before_filter :verify_feature_availability

    rescue_from Releaf::Core::AccessDenied, with: :access_denied
    rescue_from Releaf::FeatureDisabled, with: :feature_disabled

    layout :layout
    protect_from_forgery

    helper_method \
      :form_options,
      :table_options,
      :ajax?,
      :controller_scope_name,
      :current_params,
      :current_url,
      :has_template?,
      :active_view,
      :index_url,
      :page_title,
      :resource_class,
      :resource_to_text,
      :resource_to_text_method,
      :resource_edit_url,
      :feature_available?,
      :builder_class

    def search text
      return if text.blank?
      return if @searchable_fields.blank?
      @collection = Releaf::ResourceFinder.new(resource_class).search(text, @searchable_fields, @collection)
    end

    def index
      prepare_index
      respond
    end

    def new
      prepare_new
      respond
    end

    def show
      redirect_to url_for( action: 'edit', id: params[:id])
    end

    def edit
      prepare_edit
      respond
    end

    def create
      prepare_create
      result = @resource.save
      respond_after_save(:create, result, "new")
    end

    def update
      prepare_update
      result = @resource.update_attributes(resource_params)
      respond_after_save(:update, result, "edit")
    end

    def confirm_destroy
      prepare_destroy

      respond_to do |format|
        format.html do
          unless destroyable?
            @restrict_relations = list_restrict_relations
            render 'delete_restricted'
          end
        end
      end
    end

    def toolbox
      prepare_toolbox

      respond_to do |format|
        format.html do
          render 'toolbox', locals: { resource: @resource }
        end
      end
    end

    def destroy
      prepare_destroy

      action_success = destroyable? && @resource.destroy
      render_notification(action_success, failure_message_key: 'cant destroy, because relations exists')

      respond_to do |format|
        format.html { redirect_to index_url }
      end
    end

    # Check if @resource has existing restrict relation and it can be deleted
    #
    # @return boolean true or false
    def destroyable?
      resource_class.reflect_on_all_associations.all? do |assoc|
        assoc.options[:dependent] != :restrict_with_exception ||
          !@resource.send(assoc.name).exists?
      end
    end


    # Lists relations for @resource with dependent: :restrict_with_exception
    #
    # @return hash of all related objects, who have dependancy :restrict_with_exception
    def list_restrict_relations
      relations = {}
      resource_class.reflect_on_all_associations.each do |assoc|
        if assoc.options[:dependent] == :restrict_with_exception && @resource.send(assoc.name).exists?
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
    # @return controller name
    def association_controller association
      guessed_name = association.name.to_s.pluralize
      return guessed_name if Releaf.controller_list.values.map { |v| v[:controller] }.grep(/(\/#{guessed_name}$|^#{guessed_name}$)/).present?
    end


    # Helper methods ##############################################################################

    # Returns current url without internal params
    #
    # @return String
    def current_url
      if @current_url.nil?
        @current_url = request.path
        real_params = params.except(:action, :controller, :ajax)
        unless real_params.empty?
          @current_url += "?#{real_params.to_query}"
        end
      end

      @current_url
    end

    # Returns index url for current request
    #
    # @return String
    def index_url
      if @index_url.nil?
        # use current url
        if action_name == "index"
          @index_url = current_url
        # use from get params
        elsif params[:index_url].present?
          @index_url = params[:index_url]
        # fallback to index view
        else
          @index_url = url_for(action: 'index')
        end
      end

      @index_url
    end

    # Tries to return resource class.
    #
    # If it fails to return proper resource class for your controller, or your
    # controllers name has no relation to resource class name, then simply
    # override this method to return class that you want.
    #
    # @return class
    def self.resource_class
      self.name.split('::', 2).last.sub(/Controller$/, '').classify.constantize
    end

    # Tries to return resource class.
    #
    # If it fails to return proper resource class for your controller, or your
    # controllers name has no relation to resource class name, then simply
    # override this method to return class that you want.
    #
    # @return class
    def resource_class
      @resource_class ||= self.class.resource_class
    end

    # Cheheck if there is a template in lookup_context with given name.
    #
    # @return `true` or `false`
    def has_template? name
      lookup_context.template_exists?( name, lookup_context.prefixes, false )
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

    # Returns action > view translation hash
    # @return Hash
    def action_views
      {
        new: :edit,
        update: :edit,
        create: :edit,
      }
    end

    # Returns generic view name for given action
    # @return String
    def action_view(_action_name)
      action_views[_action_name.to_sym] || _action_name
    end

    # Returns generic view name for current action
    # @return String
    def active_view
      action_view(action_name)
    end

    def resource_edit_url(resource)
      if feature_available?( :edit )
        url_for( action: :edit, id: resource.try(:id), index_url: index_url )
      end
    end

    def form_url(form_type, object)
      url_for(action: object.new_record? ? 'create' : 'update', id: object.id)
    end

    def form_attributes(form_type, object, object_name)
      action = object.respond_to?(:persisted?) && object.persisted? ? :edit : :new
      {
         multipart: true,
         id: "#{action}-#{object_name}",
         class: "#{action}-#{object_name}",
         data: {
           'validation-ok-handler' => 'ajax',
           'validation' => 'true'
         }
      }
    end

    def builder_class(builder_type)
      Releaf::Builder::Utility.builder_class(self.class, resource_class, builder_type)
    end

    def form_options(form_type, object, object_name)
      {
        builder: builder_class(:form),
        as: object_name,
        url: form_url(form_type, object),
        html: form_attributes(form_type, object, object_name)
      }
    end

    def table_options
      {
        builder: builder_class(:table),
        toolbox: feature_available?(:toolbox)
      }
    end

    # return contoller translation scope name for using
    # with I18.translation call within hash params
    # ex. t("save", scope: controller_scope_name)
    def controller_scope_name
      @controller_scope_name ||= 'admin.' + self.class.name.sub(/Controller$/, '').underscore.gsub('/', '_')
    end

    def mass_assigment_actions
      ['create', 'update']
    end

    def mass_assigment_action?
      mass_assigment_actions.include? params[:action]
    end

    protected

    def respond
      respond_to do |format|
        format.html
      end
    end

    def prepare_index
      # load resource only if they are not loaded yet
      @collection = resources unless collection_given?

      search(params[:search])

      unless @resources_per_page.nil?
        @collection = @collection.page( params[:page] ).per_page( @resources_per_page )
      end
    end

    def prepare_new
      # load resource only if is not initialized yet
      @resource = resource_class.new unless resource_given?
      add_resource_breadcrumb(@resource)
    end

    def prepare_create
      # load resource only if is not loaded yet
      @resource = resource_class.new unless resource_given?
      @resource.assign_attributes(resource_params)
    end

    def prepare_edit
      # load resource only if is not loaded yet
      load_resource unless resource_given?
      add_resource_breadcrumb(@resource)
    end

    def prepare_update
      # load resource only if is not loaded yet
      load_resource unless resource_given?
    end

    def prepare_destroy
      load_resource
    end

    def prepare_toolbox
      load_resource
    end

    def load_resource
      @resource = resource_class.find(params[:id])
    end

    def verify_feature_availability
      feature = action_feature(params[:action])
      raise FeatureDisabled, feature.to_s if (feature.present? && !feature_available?(feature))
    end

    def action_feature action
      action_features[action]
    end

    def action_features
      {
        index: :index,
        new: :create,
        create: :create,
        edit: :edit,
        update: :edit,
        confirm_destroy: :destroy,
        destroy: :destroy
      }.with_indifferent_access
    end

    def feature_available? feature
      @features[feature].present?
    end

    def render_notification status, success_message_key: "#{params[:action]} succeeded", failure_message_key: "#{params[:action]} failed", now: false
      if now == true
        flash_target = flash.now
      else
        flash_target = flash
      end

      if status
        flash_target["success"] = { "id" => "resource_status", "message" => I18n.t(success_message_key, scope: notice_scope_name) }
      else
        flash_target["error"] = { "id" => "resource_status", "message" => I18n.t(failure_message_key, scope: notice_scope_name) }
      end
    end

    # Returns true if @resource is assigned (even if it's nil)
    def resource_given?
      !!defined? @resource
    end

    # Returns true if @collection is assigned (even if it's nil)
    def collection_given?
      !!defined? @collection
    end

    # Returns notice scope name
    def notice_scope_name
      'notices.' + controller_scope_name
    end

    # Return ActiveRecord::Relation used in index
    #
    # @return ActiveRecord::Relation
    def resources
      resource_class.all
    end

    def authorize! action=nil
      user = self.send("current_#{ReleafDeviseHelper.devise_admin_model_name}")
      raise Releaf::Core::AccessDenied.new(controller_name, action) unless user.role.authorize!(self, action)
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
        toolbox:           true
      }
      @panel_layout      = true
      @resources_per_page    = 40
    end

    def resource_params
      values = required_params.permit(*permitted_params)
      values = normalize_serialized_array_params(values) if normalize_serialized_array_params?
      values
    end

    # Returns which resource attributes can be updated with mass assignment.
    #
    # The resulting array will be passed to strong_parameters ``permit``
    def permitted_params
      return unless mass_assigment_action?

      cols = resource_class.column_names.dup - %w{id created_at updated_at}

      if resource_class.translates?
        cols = cols + localize_attributes(resource_class.translated_attribute_names)
      end

      cols_with_file_fields = []

      cols.each do |col|
        if col =~ /^(.+)_uid$/
          file_field = $1
          if resource_class.new.respond_to? file_field
            cols_with_file_fields.push file_field
            cols_with_file_fields.push "retained_#{file_field}"
            cols_with_file_fields.push "remove_#{file_field}"
            next
          end
        end

        cols_with_file_fields.push col
      end

      return cols_with_file_fields
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

    # Returns url to redirect after successul resource create/update actions
    #
    # @return [String] url
    def success_url
      url_for( action: 'edit', id: @resource.id )
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


    def add_resource_breadcrumb resource, url = nil
      if resource.new_record?
        name=  I18n.t('New record', scope: 'admin.breadcrumbs')
        url = url_for(action: :new, only_path: true) if url.nil?
      else
        if resource.respond_to?(:to_text)
          name = resource.send(:to_text)
        else
          name = I18n.t('Edit record', scope: 'admin.breadcrumbs')
        end
        url = url_for(action: :edit, id: resource.id, only_path: true) if url.nil?
      end
      @breadcrumbs << { name: name, url: url }
    end

    def page_title
      I18n.t(params[:controller], scope: "admin.menu_items") + " - " + Rails.application.class.parent_name
    end

    # returns all params except :controller, :action and :format
    def current_params
      params.except(:controller, :action, :format)
    end

    # set locale for interface translating from current admin user
    def set_locale
      admin = send("current_" + ReleafDeviseHelper.devise_admin_model_name)
      I18n.locale = admin.locale
    end

    def feature_disabled exception
      @feature = exception.message
      error_response('feature_disabled', 403)
    end

    def access_denied
      error_response('access_denied', 403)
    end

    def ajax?
      @_ajax || false
    end

    def layout
      ajax? ? false : Releaf.layout
    end

    private

    def manage_ajax
      @_ajax = params.has_key? :ajax
      params.delete(:ajax)
    end

    def error_response error_page, error_status
      respond_to do |format|
        format.html { render "releaf/error_pages/#{error_page}", status: error_status }
        format.any  { render text: '', status: error_status }
      end
    end

    def respond_after_save request_type, result, html_render_action
      if result
        render_notification true
      end

      respond_to do |format|
        format.json  do
          if result
            if @features[:edit_ajax_reload] && request_type == :update
              add_resource_breadcrumb(@resource)
              render action: html_render_action, formats: [:html], content_type: "text/html"
              flash.delete("success") # prevent flash on next full page reload
            else
              render json: {url: success_url, message: flash["success"]["message"]}, status: 303
            end
          else
            render json: Releaf::ErrorFormatter.format_errors(@resource), status: 422
          end
        end

        format.html do
          if result
            redirect_to success_url
          else
            render_notification false
            render action: html_render_action
          end
        end
      end
    end

  end
end
