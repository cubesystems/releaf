module Releaf::ActionController::Exceptions
  extend ActiveSupport::Concern

  included do
    rescue_from Releaf::AccessDenied, with: :access_denied
    rescue_from Releaf::RecordNotFound, with: :page_not_found
  end

  def page_not_found
    respond_with(nil, responder: action_responder(:page_not_found))
  end

  def access_denied
    respond_with(nil, responder: action_responder(:access_denied))
  end
end
