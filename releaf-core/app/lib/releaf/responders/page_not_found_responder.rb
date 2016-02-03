module Releaf::Responders
  class PageNotFoundResponder < ActionController::Responder
    include Releaf::Responders::ErrorResponder

    def status_code
      404
    end
  end
end
