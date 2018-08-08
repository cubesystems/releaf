class Releaf::ActionController < ActionController::Base
  # must be first other in stange way non-text env will
  # have CSRF on richtext attachment upload
  protect_from_forgery

  include Releaf::ActionController::Notifications
  include Releaf::ActionController::Resources
  include Releaf::ActionController::Builders
  include Releaf::ActionController::Search
  include Releaf::ActionController::Features
  include Releaf::ActionController::Ajax
  include Releaf::ActionController::Urls
  include Releaf::ActionController::Breadcrumbs
  include Releaf::ActionController::RichtextAttachments
  include Releaf::ActionController::Views
  include Releaf::ActionController::Layout
  include Releaf::ActionController::Exceptions
  include Releaf::Responders

  helper_method :controller_scope_name, :page_title

  respond_to :html
  respond_to :json, only: [:create, :update]
  layout :layout

  def index
    prepare_index
    respond_with(@collection)
  end

  def new
    prepare_new
    respond_with(@resource)
  end

  def show
    if feature_available?(:show)
      prepare_show
      respond_with(@resource)
    else
      redirect_to url_for(action: 'edit', id: params[:id])
    end
  end

  def edit
    prepare_edit
    respond_with(@resource)
  end

  def create
    prepare_create
    @resource.save
    respond_with(@resource, location: (success_path if @resource.persisted?), redirect: true)
  end

  def update
    prepare_update
    @resource.update_attributes(resource_params)
    respond_with(@resource, location: success_path)
  end

  def confirm_destroy
    prepare_destroy
    @restricted_relations = Releaf::ResourceUtilities.restricted_relations(@resource)
    respond_with(@resource, destroyable: destroyable?)
  end

  def toolbox
    prepare_toolbox
    respond_with(@resource)
  end

  def destroy
    prepare_destroy
    @resource.destroy if destroyable?
    respond_with(@resource, location: index_path)
  end

  def prepare_index
    # load resource only if they are not loaded yet
    @collection = resources unless collection_given?

    search(params[:search])

    unless resources_per_page.nil?
      @collection = @collection.page( params[:page] ).per_page( resources_per_page )
    end
  end

  def prepare_new
    # load resource only if is not initialized yet
    new_resource unless resource_given?
    add_resource_breadcrumb(@resource)
  end

  def prepare_create
    # load resource only if is not initialized yet
    new_resource unless resource_given?
    @resource.assign_attributes(resource_params)
  end

  def prepare_show
    prepare_resource_view
  end

  def prepare_edit
    prepare_resource_view
  end

  def prepare_resource_view
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

  # Returns true if @collection is assigned (even if it's nil)
  def collection_given?
    !!defined? @collection
  end

  def required_params
    params.require(:resource)
  end

  def create_another?
    params[:after_save] == "create_another" && feature_available?(:create_another)
  end

  # Check if @resource has existing restrict relation and it can be deleted
  #
  # @return boolean true or false
  def destroyable?
    Releaf::ResourceUtilities.destroyable?(@resource)
  end

  # return contoller translation scope name for using
  # with I18.translation call within hash params
  # ex. t("save", scope: controller_scope_name)
  def controller_scope_name
    @controller_scope_name ||= 'admin.' + self.class.name.sub(/Controller$/, '').underscore.tr('/', '_')
  end

  def page_title
    title = Rails.application.class.parent_name
    title = "#{definition.localized_name} - #{title}" if definition

    title
  end

  def short_name
    self.class.name.sub(/Controller$/, "").underscore
  end

  def definition
    Releaf::ControllerDefinition.for(short_name)
  end

  ActiveSupport.run_load_hooks(:base_controller, self)
end
