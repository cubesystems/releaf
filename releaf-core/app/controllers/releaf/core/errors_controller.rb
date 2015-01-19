class Releaf::Core::ErrorsController < ::Releaf::BaseController
  def page_not_found
    error_response('page_not_found', 404)
  end
end
