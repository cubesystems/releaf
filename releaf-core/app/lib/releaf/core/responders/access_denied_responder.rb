module Releaf::Core::Responders
  class AccessDeniedResponder < ActionController::Responder
    include Releaf::Core::Responders::ErrorResponder

    def status_code
      403
    end
  end
end
