module Releaf::Responders
  class FeatureDisabledResponder < ActionController::Responder
    include Releaf::Responders::ErrorResponder

    def status_code
      403
    end
  end
end
