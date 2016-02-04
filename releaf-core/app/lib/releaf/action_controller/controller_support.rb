module Releaf::ActionController::ControllerSupport
  extend ActiveSupport::Concern

  included do
    include Releaf::ActionController::Notifications
    include Releaf::ActionController::Resources
    include Releaf::ActionController::Builders
    include Releaf::ActionController::Search
    include Releaf::ActionController::Features
    include Releaf::ActionController::Ajax
    include Releaf::ActionController::Urls
    include Releaf::ActionController::Breadcrumbs
    include Releaf::ActionController::RichtextAttachments
    include Releaf::Responders

    helper_method :controller_scope_name, :active_view, :page_title
      rescue_from Releaf::AccessDenied, with: :access_denied

      respond_to :html
      respond_to :json, only: [:create, :update]
      protect_from_forgery
      layout :layout

    def short_name
      self.class.name.gsub("Controller", "").underscore
    end
  end

  # Returns true if @collection is assigned (even if it's nil)
  def collection_given?
    !!defined? @collection
  end

  # Returns notice scope name
  def notice_scope_name
    'notices.' + controller_scope_name
  end

  def required_params
    params.require(:resource)
  end

  def create_another?
    params[:after_save] == "create_another" && feature_available?(:create_another)
  end

  def access_denied
    respond_with(nil, responder: action_responder(:access_denied))
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
    @controller_scope_name ||= 'admin.' + self.class.name.sub(/Controller$/, '').underscore.gsub('/', '_')
  end

  def page_title
    I18n.t(params[:controller], scope: "admin.controllers") + " - " + Rails.application.class.parent_name
  end
end
