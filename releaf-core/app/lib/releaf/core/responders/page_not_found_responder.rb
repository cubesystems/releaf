module Releaf::Core::Responders
  class PageNotFoundResponder < ActionController::Responder
    include Releaf::Core::Responders::ErrorResponder

    def status_code
      404
    end
  end
end
