class Releaf::Core::ErrorsController < Releaf::BaseController
  def page_not_found
    respond_with(nil, responder: action_responder(:page_not_found))
  end
end
