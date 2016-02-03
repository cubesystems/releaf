module Releaf::Responders
  class AccessDeniedResponder < ActionController::Responder
    include Releaf::Responders::ErrorResponder

    def status_code
      403
    end
  end
end
