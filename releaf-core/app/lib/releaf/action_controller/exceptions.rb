module Releaf::ActionController::Exceptions
  extend ActiveSupport::Concern

  included do
    rescue_from Releaf::AccessDenied, with: :access_denied
    rescue_from Releaf::RecordNotFound, with: :page_not_found
  end

  def page_not_found
    render "releaf/error_pages/page_not_found", status: :not_found, formats: :html
  end

  def access_denied
    render "releaf/error_pages/forbidden", status: :forbidden, formats: :html
  end
end
