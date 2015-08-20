module Releaf
  class FeatureDisabled < StandardError; end

  class BaseController < ActionController::Base
    respond_to :html
    respond_to :json, only: [:create, :update]
    protect_from_forgery
    include Releaf.access_control_module
    include Releaf::Breadcrumbs
    include Releaf::RichtextAttachments
    include Releaf::Responders

    before_filter :manage_ajax, :setup, :verify_feature_availability!

    rescue_from Releaf::Core::AccessDenied, with: :access_denied
    rescue_from Releaf::FeatureDisabled, with: :feature_disabled

    layout :layout

    helper_method \
      :form_options,
      :table_options,
      :ajax?,
      :controller_scope_name,
      :current_params,
      :current_url,
      :active_view,
      :index_url,
      :page_title,
      :resource_class,
      :feature_available?,
      :builder_class

    def search(text)
      return if text.blank?
      return if searchable_fields.blank?
      @collection = searcher_class.prepare(relation: @collection, fields: searchable_fields, text: text)
    end

    def searcher_class
      Releaf::Core::Search
    end

    def index
      prepare_index
      respond_with(@collection)
    end

    def new
      prepare_new
      respond_with(@resource)
    end

    def show
      redirect_to url_for( action: 'edit', id: params[:id])
    end

    def edit
      prepare_edit
      respond_with(@resource)
    end

    def create
      prepare_create
      @resource.save
      respond_with(@resource, location: (success_url if @resource.persisted?), redirect: true)
    end

    def update
      prepare_update
      @resource.update_attributes(resource_params)
      respond_with(@resource, location: success_url)
    end

    def confirm_destroy
      prepare_destroy
      @restricted_relations = restricted_relations unless destroyable?
      respond_with(@resource, destroyable: destroyable?)
    end

    def toolbox
      prepare_toolbox
      respond_with(@resource)
    end

    def destroy
      prepare_destroy
      @resource.destroy if destroyable?
      respond_with(@resource, location: index_url)
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
    def restricted_relations
      relations = {}
      resource_class.reflect_on_all_associations.each do |assoc|
        if assoc.options[:dependent] == :restrict_with_exception && @resource.send(assoc.name).exists?
          relations[assoc.name.to_sym] = {
            objects:    @resource.send(assoc.name),
            controller: association_controller(assoc)
          }
        end
      end

      relations
    end

    # Attempts to guess associated controllers name
    #
    # @return controller name
    def association_controller association
      guessed_name = association.name.to_s.pluralize
      guessed_name if Releaf.controller_list.values.map { |v| v[:controller] }.grep(/(\/#{guessed_name}$|^#{guessed_name}$)/).present?
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
          "remote" => true,
          "remote-validation" => true,
          "type" => :json,
        },
        novalidate: ''
      }
    end

    def builder_class(builder_type)
      Releaf::Builders.builder_class(builder_scopes, builder_type)
    end

    def application_builder_scope
      [application_scope, "Builders"].reject(&:blank?).join("::")
    end

    def application_scope
      scope = Releaf.mount_location.capitalize
      scope if scope.present? && Releaf::Builders.constant_defined_at_scope?(scope, Object)
    end

    def builder_scopes
      [self.class.name.gsub(/Controller$/, ""), application_builder_scope]
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

    def feature_available? feature
      @features[feature].present?
    end

    def page_title
      I18n.t(params[:controller], scope: "admin.controllers") + " - " + Rails.application.class.parent_name
    end

    def render_notification(status, success_message_key: "#{params[:action]} succeeded", failure_message_key: "#{params[:action]} failed", now: false)
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

    def prepare_index
      # load resource only if they are not loaded yet
      @collection = resources unless collection_given?

      search(params[:search])

      unless @resources_per_page.nil?
        @collection = @collection.page( params[:page] ).per_page( @resources_per_page )
      end
    end

    def prepare_new
      new_resource unless resource_given?
      add_resource_breadcrumb(@resource)
    end

    def prepare_create
      new_resource unless resource_given?
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

    def new_resource
      # load resource only if is not initialized yet
      @resource = resource_class.new
    end

    def load_resource
      @resource = resource_class.find(params[:id])
    end

    def verify_feature_availability!
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
        create:            true,
        destroy:           true,
        index:             true,
        toolbox:           true
      }
      @panel_layout = true
      @resources_per_page = 40
    end

    def searchable_fields
      @searchable_fields ||= Releaf::Core::DefaultSearchableFields.new(resource_class).find
    end

    def resource_params
      required_params.permit(*permitted_params)
    end

    # Returns which resource attributes can be updated with mass assignment.
    #
    # The resulting array will be passed to strong_parameters ``permit``
    def permitted_params
      Releaf::Core::ResourceParams.new(resource_class).values
    end

    # Returns url to redirect after successul resource create/update actions
    #
    # @return [String] url
    def success_url
      url_for(action: 'edit', id: @resource.id, index_url: index_url)
    end

    # returns all params except :controller, :action and :format
    def current_params
      params.except(:controller, :action, :format)
    end

    def feature_disabled exception
      @feature = exception.message
      respond_with(nil, responder: action_responder(:feature_disabled))
    end

    def access_denied
      respond_with(nil, responder: action_responder(:access_denied))
    end

    def ajax?
      @_ajax || false
    end

    def layout
      ajax? ? false : "releaf/admin"
    end

    def manage_ajax
      @_ajax = params.has_key? :ajax
      params.delete(:ajax)
    end
  end
end
